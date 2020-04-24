import os
import subprocess
import sys
import shutil


class JavaNotFoundException(Exception):
    """
    This exception is raised if the Java executable is not found
    either through $JAVA_HOME or $PATH.
    """
    def __init__(self):
        super(self).__init__("Java was not found (checked $JAVA_HOME and $PATH).")


zs_jar_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "zserio.jar")
java_path = os.getenv("JAVA_HOME", None)
if java_path:
    java_path = os.path.join(java_path, "bin/java")
    print(f"Using Java at {java_path} (found through $JAVA_HOME).")
else:
    java_path = shutil.which("java")
    if java_path:
        print(f"Using Java at {java_path} (found through $PATH).")
    else:
        raise JavaNotFoundException()


def require(src_file: str = "", *, package_prefix: str = ""):
    """
    Description:

        Translate zserio code to python, and add the generated package
        to pythonpath. The generated sources will be placed under
        <src_file.zs>/../.zs-python-package/. This path will be added to sys.path.

    Example:

        ```
        import zserio
        zserio.require("myfile.zs")
        from myfile import *
        ```

    :param src_file: Source zserio file.
    :return: True if succesfull, False otherwise.
    """
    global zs_jar_path
    if not zs_jar_path:
        print("""
        ERROR: Zserio not installed. Call `setup()` before
        running `package()`, or set `zswag.zs_jar_path`.
        """)
        return False
    zs_pkg_path = os.path.dirname(os.path.abspath(src_file))
    zs_build_path = os.path.join(zs_pkg_path, ".zs-python-package")
    subprocess.run([
        java_path, "-jar", zs_jar_path,
        "-src", zs_pkg_path,
        "-python", zs_build_path,
        *(("-setTopLevelPackage", package_prefix) if package_prefix else tuple()),
        os.path.basename(src_file)])
    if zs_build_path not in sys.path:
        sys.path.append(zs_build_path)
    return True
