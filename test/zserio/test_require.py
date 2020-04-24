
def test_require():
    import zserio
    zserio.require("test/zserio/test.zs", package_prefix="test_package")
    from test_package.Test import Test
