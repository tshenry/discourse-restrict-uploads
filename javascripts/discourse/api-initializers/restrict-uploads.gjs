import { apiInitializer } from "discourse/lib/api";
import discourseComputed from "discourse/lib/decorators";

export default apiInitializer((api) => {
  const currentUser = api.getCurrentUser();
  const minTrust = settings.restrict_to_trust_level;

  const canUpload = currentUser?.trust_level >= minTrust || currentUser?.staff;

  const noImagePlaceholders = new Set([
    "composer.reply_placeholder_rte",
    "composer.reply_placeholder",
  ]);

  api.modifyClass(
    "service:composer",
    (SuperClass) =>
      class extends SuperClass {
        @discourseComputed
        allowUpload() {
          return super.allowUpload && canUpload;
        }
      }
  );

  api.registerValueTransformer(
    "composer-editor-reply-placeholder",
    ({ value }) =>
      !canUpload && noImagePlaceholders.has(value)
        ? `${value}_no_images`
        : value
  );

  api.addComposerUploadHandler(["*"], () => {
    return canUpload;
  });
});
