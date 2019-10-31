// Copyright 2018-present 650 Industries. All rights reserved.

#import <UMCore/UMEventEmitterService.h>
#import <EXOta/EXOtaModule.h>
#import <EXOta/EXKeyValueStorage.h>
#import <EXOta/EXOtaPersistance.h>
#import "EXOtaPersistanceFactory.h"
#import "EXOtaEvents.h"
#import "EXOtaUpdaterFactory.h"
#import <EXOtaUpdater.h>
#import <EXExpoUpdatesConfig.h>
#import <EXEmbeddedManifestAndBundle.h>

@interface EXOtaModule ()

@property (nonatomic, weak) UMModuleRegistry *moduleRegistry;
@property (nonatomic, weak) id<UMEventEmitterService> eventEmitter;

@end

@implementation EXOtaModule {
    EXOtaUpdater *updater;
    EXOtaPersistance *persistance;
    NSString *appId;
    EXOtaEvents *events;
}

UM_EXPORT_MODULE(ExpoOta);

- (id)init
{
    return [self configure:@"defaultId"];
}

- (id)initWithId:(NSString *)appId
{
    return [self configure:appId];
}

- (id)configure:(NSString* _Nullable)appId
{
    self->appId = appId;
    persistance = [[EXOtaPersistanceFactory sharedFactory] persistanceForId:appId];
    updater = [[EXOtaUpdaterFactory sharedFactory] updaterForId:appId initWithConfig:persistance.config withPersistance:persistance];
    return self;
}

- (void)setModuleRegistry:(UMModuleRegistry *)moduleRegistry
{
    _moduleRegistry = moduleRegistry;
    _eventEmitter = [moduleRegistry getModuleImplementingProtocol:@protocol(UMEventEmitterService)];
    events = [[EXOtaEvents alloc] initWithEmitter:_eventEmitter];
    updater.eventsEmitter = events;
}

UM_EXPORT_METHOD_AS(checkForUpdateAsync,
                    checkForUpdateAsync:(UMPromiseResolveBlock)resolve
                    reject:(UMPromiseRejectBlock)reject)
{
    [updater downloadManifest:^(NSDictionary * _Nonnull manifest) {
        if([self isManifestNewer:manifest])
        {
            resolve(manifest);
        } else
        {
            resolve(@NO);
        }
    } error:^(NSError * _Nonnull error) {
        reject(@"ERR_EXPO_OTA", @"Could not download manifest", error);
    }];
}

- (BOOL) isManifestNewer:(NSDictionary * _Nonnull)manifest
{
    return [persistance.config.manifestComparator shouldReplaceBundle:[persistance readNewestManifest] forNew:manifest];
}

UM_EXPORT_METHOD_AS(fetchUpdateAsync,
                    fetchUpdateAsync:(UMPromiseResolveBlock)resolve
                    reject:(UMPromiseRejectBlock)reject)
{
    [updater checkAndDownloadUpdate:^(NSDictionary * _Nonnull manifest, NSString * _Nonnull filePath) {
        [self->updater saveDownloadedManifest:manifest andBundlePath:filePath];
        resolve(@{
            @"manifest": manifest
        });
    } updateUnavailable:^{
        resolve(nil);
    }   error:^(NSError * _Nonnull error) {
        reject(@"ERR_EXPO_OTA", @"Could not download update", error);
    }];
}

UM_EXPORT_METHOD_AS(clearUpdateCacheAsync,
                    clearUpdateCacheAsync:(UMPromiseResolveBlock)resolve
                    reject:(UMPromiseRejectBlock)reject)
{
    [updater cleanUnusedFiles];
    resolve(@YES);
}

UM_EXPORT_METHOD_AS(reload,
                    reload:(UMPromiseResolveBlock)resolve
                    reject:(UMPromiseRejectBlock)reject)
{
    [updater scheduleForExchangeAtNextBoot];
    resolve(@YES);
}

UM_EXPORT_METHOD_AS(reloadFromCache,
                    reloadFromCache:(UMPromiseResolveBlock)resolve
                    reject:(UMPromiseRejectBlock)reject)
{
    [self reload:resolve reject:reject];
}

UM_EXPORT_METHOD_AS(readCurrentManifestAsync,
                    readCurrentManifestAsync:(UMPromiseResolveBlock)resolve
                    reject:(UMPromiseRejectBlock)reject)
{
    resolve([[EXEmbeddedManifestAndBundle alloc] readManifest]);
}

# pragma mark - UMEventEmitter

- (NSArray<NSString *> *)supportedEvents
{
    return [events supportedEvents];
}

- (void)startObserving {}


- (void)stopObserving {}

@end
