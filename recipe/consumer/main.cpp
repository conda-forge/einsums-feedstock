#include <Einsums/ComputeGraph.hpp>
#include <Einsums/Runtime.hpp>
#include <Einsums/TensorUtilities/CreateRandomTensor.hpp>
#include <Einsums/TensorUtilities/CreateZeroTensor.hpp>

#include <algorithm>
#include <cmath>
#include <cstdio>

int einsums_main() {
    using namespace einsums;
    namespace cg = einsums::compute_graph;

    auto A = create_random_tensor<double>("A", 7, 5);
    auto B = create_random_tensor<double>("B", 5, 3);
    auto C = create_zero_tensor<double>("C", 7, 3);

    cg::einsum("ik;kj->ij", &C, A, B);

    double worst = 0.0;
    for (std::size_t i = 0; i < 7; i++) {
        for (std::size_t j = 0; j < 3; j++) {
            double want = 0.0;
            for (std::size_t k = 0; k < 5; k++) {
                want += A(i, k) * B(k, j);
            }
            worst = std::max(worst, std::abs(C(i, j) - want));
        }
    }
    std::printf("consumer: largest error %g\n", worst);

    finalize();
    return worst < 1e-12 ? 0 : 1;
}

int main(int argc, char **argv) {
    return einsums::start(einsums_main, argc, argv);
}
