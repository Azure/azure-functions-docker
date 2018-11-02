import subprocess
import traceback

CACHE_LOCATION = '/usr/local/cached_packages/'
REQUIREMENTS = '/usr/local/cached_requirements.txt'

def main():
    try:
        packages = []
        with open(REQUIREMENTS, 'r') as package_list_file:
            packages = package_list_file.readlines()
        for package in packages:
            package = package.strip()
            target = '--target=' + CACHE_LOCATION + package
            subprocess.call(['pip', 'install', '--no-deps', target, package])
    except Exception:
        traceback.print_exc()

if __name__ == '__main__':
    main()