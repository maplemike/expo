import { canUseDOM } from 'fbjs/lib/ExecutionEnvironment';
export default {
    get name() {
        return 'ExponentUpdates';
    },
    async reload() {
        if (!canUseDOM)
            return;
        location.reload(true);
    },
    async reloadFromCache() {
        if (!canUseDOM)
            return;
        location.reload(true);
    },
};
//# sourceMappingURL=ExponentUpdates.web.js.map