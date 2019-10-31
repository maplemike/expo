import { EventEmitter, NativeModulesProxy, UnavailabilityError } from '@unimodules/core';
import Constants from 'expo-constants';

const OTA = NativeModulesProxy.ExpoOta;

const OTAEventEmitter = new EventEmitter(OTA);

type Manifest = typeof Constants.manifest;

type UpdateEvent =
  | { type: 'downloadStart' | 'downloadProgress' | 'noUpdateAvailable' }
  | { type: 'downloadFinished'; manifest: Manifest }
  | { type: 'error'; message: string };

type UpdateCheckResult = { isAvailable: false } | { isAvailable: true; manifest: Manifest };

type UpdateEventListener = (event: UpdateEvent) => void;

export interface PedometerEventSubscribtion {
  remove: () => void;
}

type UpdateFetchResult = { isNew: false } | { isNew: true; manifest: Manifest };

export async function checkForUpdateAsync(): Promise<UpdateCheckResult> {
  if (!OTA.checkForUpdateAsync) {
    throw new UnavailabilityError('Updates', 'checkForUpdateAsync');
  }
  const result = await OTA.checkForUpdateAsync();
  if (!result) {
    return { isAvailable: false };
  }

  return {
    isAvailable: true,
    manifest: typeof result === 'string' ? JSON.parse(result) : result,
  };
}

export async function fetchUpdateAsync({
  eventListener,
}: { eventListener?: UpdateEventListener } = {}): Promise<UpdateFetchResult> {
  if (!OTA.fetchUpdateAsync) {
    throw new UnavailabilityError('Updates', 'fetchUpdateAsync');
  }
  let subscription;
  let result;
  if (eventListener && typeof eventListener === 'function') {
    subscription = addListener(eventListener);
  }
  try {
    result = await OTA.fetchUpdateAsync();
  } finally {
    subscription && subscription.remove();
  }

  if (!result) {
    return { isNew: false };
  }

  return {
    isNew: true,
    manifest: typeof result === 'string' ? JSON.parse(result) : result,
  };
}

export async function reload() {
  if (!OTA.reload) {
    throw new UnavailabilityError('WebBrowser', 'reload');
  }
  return OTA.reload();
}

export async function clearUpdateCacheAsync() {
  if (!OTA.clearUpdateCacheAsync) {
    throw new UnavailabilityError('WebBrowser', 'clearUpdateCacheAsync');
  }
  return OTA.clearUpdateCacheAsync();
}

export async function readCurrentManifestAsync() {
  if (!OTA.readCurrentManifestAsync) {
    throw new UnavailabilityError('WebBrowser', 'getCustomTabsSupportingBrowsersAsync');
  }
  return OTA.readCurrentManifestAsync().then(result => typeof result === 'string' ? JSON.parse(result) : result);
}

export function addListener(listener: UpdateEventListener): PedometerEventSubscribtion {
  return OTAEventEmitter.addListener('Exponent.updatesEvent', listener);
}

export const EventType = {
  DOWNLOAD_STARTED: 'downloadStart',
  DOWNLOAD_PROGRESS: 'downloadProgress',
  DOWNLOAD_FINISHED: 'downloadFinished',
  NO_UPDATE_AVAILABLE: 'noUpdateAvailable',
  ERROR: 'error',
};
