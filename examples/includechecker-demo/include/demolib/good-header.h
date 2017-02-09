#pragma once

#include <string>
#include <memory>

namespace demolib {

inline std::unique_ptr<std::string> new_unique_string() {
    return std::make_unique<std::string>("hi");
}

}


