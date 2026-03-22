const TRUST_LEVEL_TO_GROUP = {
  0: 10,
  1: 11,
  2: 12,
  3: 13,
  4: 14,
};

export default function migrate(settings) {
  if (!settings.has("restrict_to_trust_level")) {
    return settings;
  }

  const trustLevel = Number(settings.get("restrict_to_trust_level"));
  if (Number.isNaN(trustLevel)) {
    settings.delete("restrict_to_trust_level");
    return settings;
  }

  const groupIds = [];

  const mappedGroup = TRUST_LEVEL_TO_GROUP[trustLevel];

  if (mappedGroup !== undefined) {
    groupIds.push(mappedGroup);
  }

  groupIds.push(3);

  settings.set("restricted_to_groups", groupIds.join("|"));
  settings.delete("restrict_to_trust_level");

  return settings;
}
