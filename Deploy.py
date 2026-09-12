import os
import shutil
import subprocess

# Paths
SOURCE_DIR = r"c:\Users\Eren\Desktop\-\Projeler\HadesBuildHelper"
TARGET_DIR = r"C:\Program Files (x86)\Steam\steamapps\common\Hades\Content\Mods\HadesBuildHelper"
CONTENT_DIR = r"C:\Program Files (x86)\Steam\steamapps\common\Hades\Content"
MOD_IMPORTER = os.path.join(CONTENT_DIR, "modimporter.exe")

print("Deploying HadesBuildHelper...")

# 1. Copy files
if not os.path.exists(TARGET_DIR):
    os.makedirs(TARGET_DIR)

for item in os.listdir(SOURCE_DIR):
    # Ignore git and the deployment script itself
    if item in [".git", "__pycache__", "Deploy.py"]:
        continue
    s = os.path.join(SOURCE_DIR, item)
    d = os.path.join(TARGET_DIR, item)
    if os.path.isdir(s):
        shutil.copytree(s, d, dirs_exist_ok=True)
    else:
        shutil.copy2(s, d)

print(f"Files copied successfully from {SOURCE_DIR} to {TARGET_DIR}.")

# 2. Run Mod Importer
print("Running modimporter.exe...")
# Mod importer must be run from the Content directory
os.chdir(CONTENT_DIR) 
result = subprocess.run([MOD_IMPORTER], capture_output=True, text=True)

print("--- Mod Importer Output ---")
print(result.stdout)
if result.stderr:
    print("--- Errors ---")
    print(result.stderr)

print("Deploy complete! You can now launch/test the game.")
