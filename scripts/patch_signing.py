path = "ios/Runner.xcodeproj/project.pbxproj"
with open(path, encoding="utf-8") as f:
    content = f.read()

# 1. CODE_SIGN_STYLE: Automatic → Manual (XCBuildConfiguration)
content = content.replace(
    "CODE_SIGN_STYLE = Automatic;",
    "CODE_SIGN_STYLE = Manual;",
)

# 2. CODE_SIGN_IDENTITY: iPhone Developer → Apple Distribution
content = content.replace(
    '"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";',
    '"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Apple Distribution";',
)

# 3. PROVISIONING_PROFILE_SPECIFIER — inserer dans les configs Runner (pas RunnerTests)
# Le pattern unique: PRODUCT_BUNDLE_IDENTIFIER sans .RunnerTests suivi de
# CODE_SIGN_ENTITLEMENTS (present depuis l'ajout des entitlements Push).
content = content.replace(
    'PRODUCT_BUNDLE_IDENTIFIER = org.fbpm.fooyreApp;\n\t\t\t\tCODE_SIGN_ENTITLEMENTS',
    'PRODUCT_BUNDLE_IDENTIFIER = org.fbpm.fooyreApp;\n'
    '\t\t\t\tPROVISIONING_PROFILE_SPECIFIER = "Fooyre App";\n'
    '\t\t\t\tCODE_SIGN_ENTITLEMENTS',
)

# 4. TargetAttributes Runner: ajouter ProvisioningStyle = Manual
# Xcode 26 lit cette cle pour determiner si le signing est Automatic ou Manual
old_target = (
    "\t\t\t\t\t\tLastSwiftMigration = 1100;\n"
    "\t\t\t\t\t};"
)
new_target = (
    "\t\t\t\t\t\tLastSwiftMigration = 1100;\n"
    "\t\t\t\t\t\tProvisioningStyle = Manual;\n"
    "\t\t\t\t\t};"
)
content = content.replace(old_target, new_target)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

# Verification
manual_count = content.count("CODE_SIGN_STYLE = Manual;")
dist_count = content.count("Apple Distribution")
prov_count = content.count("ProvisioningStyle = Manual")
print(f"CODE_SIGN_STYLE = Manual:     {manual_count} occurrences")
print(f"Apple Distribution:            {dist_count} occurrences")
print(f"ProvisioningStyle = Manual:    {prov_count} occurrence(s)")
print("project.pbxproj patched successfully")
