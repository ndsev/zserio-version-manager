
def test_generate():
    import zserio
    zserio.generate("test/zserio/test.zs", "test_package")
    from test_package.Test import Test
