import PyInstaller.__main__
import shutil
import os
import sys
import glob

base_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(base_dir)

ui_entry = os.path.join(base_dir, 'UI.py')
src_dir = os.path.join(base_dir, 'src')
sdk_dir = os.path.join(project_root, 'PYTHON_SDK')

if not os.path.exists(sdk_dir):
    print(f"Error: PYTHON_SDK directory not found: {sdk_dir}")
    sys.exit(1)

if sys.platform == 'win32':
    pack_args = [
        ui_entry,
        '--onefile',
        # '--windowed',
        '--icon', os.path.join(src_dir, 'logo.ico'),
        '--name', 'FXPlatform',
        '--add-binary', os.path.join(sdk_dir, 'libGentoSDKPY.dll') + ';.',
        '--paths', sdk_dir,
        '--hidden-import', 'ctypes',
    ]
    pack_args.extend(['--add-binary', os.path.join(sdk_dir, '*.dll') + ';.'])
    pack_args.extend(['--add-data', os.path.join(sdk_dir, '*.py') + ';PYTHON_SDK'])
    pack_args.extend(['--add-data', os.path.join(src_dir, 'logo.ico') + ';src'])
else:
    pack_args = [
        ui_entry,
        '--onefile',
        '--windowed',
        '--icon', os.path.join(src_dir, 'logo.png'),
        '--name', 'FXPlatform',
        '--add-binary', os.path.join(sdk_dir, 'libGentoSDKPY.so') + ':.',
        '--paths', sdk_dir,
        '--hidden-import', 'ctypes',
        '--hidden-import', 'PIL._tkinter_finder',
        '--hidden-import', 'PIL.Image',
        '--hidden-import', 'PIL.ImageTk',
    ]
    pack_args.extend(['--add-binary', os.path.join(sdk_dir, '*.so') + ':.'])
    pack_args.extend(['--add-data', os.path.join(sdk_dir, '*.py') + ':PYTHON_SDK'])
    pack_args.extend(['--add-data', os.path.join(src_dir, 'logo.png') + ':src'])



PyInstaller.__main__.run(pack_args)

print("Cleaning temporary files...")
shutil.rmtree(os.path.join(base_dir, 'build'), ignore_errors=True)
shutil.rmtree(os.path.join(base_dir, '__pycache__'), ignore_errors=True)
sdk_pycache = os.path.join(sdk_dir, '__pycache__')
shutil.rmtree(sdk_pycache, ignore_errors=True)

exe_files = glob.glob(os.path.join(base_dir, 'dist', '*.exe'))
if exe_files:
    exe_path = exe_files[0]
    target_path = os.path.join(project_root, os.path.basename(exe_path))
    print(f"Moving {exe_path} -> {target_path}")
    shutil.move(exe_path, target_path)
else:
    print("Warning: No .exe file found in dist directory")

print("Deleting dist folder...")
shutil.rmtree(os.path.join(base_dir, 'dist'), ignore_errors=True)

spec_files = glob.glob(os.path.join(base_dir, '*.spec'))
for spec_file in spec_files:
    print(f"Deleting {spec_file}")
    os.remove(spec_file)

print("Packaging completed! Executable file is in the project root directory.")