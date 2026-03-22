import { module, test } from "qunit";
import migrate from "../../../../migrations/settings/0001-migrate-trust-level-to-groups";

module(
  "Unit | Migrations | Settings | 0001-migrate-trust-level-to-groups",
  function () {
    test("migrate trust level 2 to groups", function (assert) {
      const settings = new Map(Object.entries({ restrict_to_trust_level: 2 }));
      const result = migrate(settings);
      assert.deepEqual(
        Array.from(result),
        Array.from(new Map(Object.entries({ restricted_to_groups: "12|3" })))
      );
    });

    test("migrate trust level 0 to groups", function (assert) {
      const settings = new Map(Object.entries({ restrict_to_trust_level: 0 }));
      const result = migrate(settings);
      assert.deepEqual(
        Array.from(result),
        Array.from(new Map(Object.entries({ restricted_to_groups: "10|3" })))
      );
    });

    test("does not migrate when setting is absent", function (assert) {
      const settings = new Map(Object.entries({}));
      const result = migrate(settings);
      assert.deepEqual(Array.from(result), Array.from(settings));
    });

    test("does not crash on invalid value", function (assert) {
      const settings = new Map(
        Object.entries({ restrict_to_trust_level: "invalid" })
      );
      const result = migrate(settings);
      assert.deepEqual(Array.from(result), Array.from(new Map()));
    });

    test("old setting is deleted after migration", function (assert) {
      const settings = new Map(Object.entries({ restrict_to_trust_level: 2 }));
      const result = migrate(settings);
      assert.false(result.has("restrict_to_trust_level"));
    });
  }
);
