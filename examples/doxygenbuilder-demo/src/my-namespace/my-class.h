#include <string>

#pragma once

/**
 * @brief My namespace
 *
 * My namespace description.
 */
namespace MyNamespace {

/**
 * @brief My class brief.
 *
 * My class description.
 */
class MyClass {
public:
    MyClass();

    ~MyClass() = default;

    /**
     * @brief My method brief.
     * @param arg a string argument.
     *
     * My method description. Here is an example of calling my method:
     * * @snippet example-1.cpp Calling my method.
     */
    void myMethod(const std::string& arg) const;

    /**
     * @brief My other method brief.
     *
     * My other method description. Here is an example of calling my
     * other method:
     * @snippet example-1.cpp Calling my other method.
     */
    int myOtherMethod();
};

}
