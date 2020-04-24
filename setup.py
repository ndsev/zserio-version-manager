import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

required_url = []
required = []
with open("requirements.txt", "r") as freq:
    for line in freq.read().split():
        if "://" in line:
            required_url.append(line)
        else:
            required.append(line)

with open("zserio-version.txt", "r") as version_file:
    version = version_file.read().strip()

packages = setuptools.find_packages("src")

setuptools.setup(
    name="zserio",
    version=version,
    url="http://zserio.org",
    author="Navigation Data Standard e.V.",
    author_email="support@nds-association.org",

    description="Zserio runtime and Python package builder.",
    long_description=long_description,
    long_description_content_type="text/markdown",

    package_dir={'': 'src'},
    packages=packages,
    include_package_data=True,
    package_data={
        'zserio': ['zserio.jar']
    },

    install_requires=required,
    dependency_links=required_url,
    python_requires='>=3.6',

    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
)
