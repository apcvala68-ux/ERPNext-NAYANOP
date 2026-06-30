from setuptools import setup, find_packages

with open("requirements.txt") as f:
    install_requires = f.read().strip().split("\n")

setup(
    name="automotive_crm",
    version="0.1.0",
    description="Enterprise-grade CRM for automotive parts manufacturers",
    author="Your Organization",
    author_email="admin@yourorg.com",
    packages=["automotive_crm", "automotive_crm.automotive_crm"],
    zip_safe=False,
    include_package_data=True,
    install_requires=install_requires,
)
