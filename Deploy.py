import os
import shutil

# Paths
SOURCE_DIR = r"c:\Users\Eren\Desktop\-\Projeler\HadesBuildHelper"
TARGET_DIR = r"C:\Program Files (x86)\Steam\steamapps\common\Hades\Content\Mods\HadesBuildHelper"

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
print("Deploy complete! Please run modimporter.exe manually.")
