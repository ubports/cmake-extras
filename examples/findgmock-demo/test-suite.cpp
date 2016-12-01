#include <gtest/gtest.h>

TEST(Suite, Success)
{
    EXPECT_EQ(42, 42);
}

TEST(Suite, Failure)
{
    FAIL();
}
