//==============================================================================
//
//  @@-COPYRIGHT-START-@@
//
//  Copyright (c) 2020-2022, Qualcomm Innovation Center, Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  3. Neither the name of the copyright holder nor the names of its contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  SPDX-License-Identifier: BSD-3-Clause
//
//  @@-COPYRIGHT-END-@@
//
//==============================================================================

#ifdef GOOGLE_CUDA

#define EIGEN_USE_GPU
#define EIGEN_USE_THREADS

#include "AimetOpUtils.h"

using namespace tensorflow;

#define EIGEN_USE_GPU
typedef Eigen::GpuDevice GPUDevice;


// GPU specialization of actual computations.
template <typename T>
void copyInputTensorsToOutputTensors(const GPUDevice& d, const T* inTensor, size_t count, T* outTensor)
{
    // copy input_tensor to output_tensor
    cudaMemcpy(outTensor, inTensor, count * sizeof(float), cudaMemcpyDeviceToDevice);
}

template <typename T>
T copyLiteralToHost(const GPUDevice& d, const T* deviceValue)
{
    T hostValue;
    cudaMemcpy(&hostValue, deviceValue, sizeof(T), cudaMemcpyDeviceToHost);

    return hostValue;
}

void sliceTensorAlongLastDim(const GPUDevice& d, Tensor slicedTensor, const Tensor& tensorToSlice, int channel)
{
    // K x K x I x O -> N x O
    auto tensorToSliceTwoDim = tensorToSlice.flat_inner_dims<float, 2>();
    slicedTensor.tensor<float, 2>().chip<0>(0).device(d) = tensorToSliceTwoDim.chip<1>(channel);

}

void sliceAndStoreTensor(const GPUDevice& d, Tensor* slicedTensor, Tensor tensorToSlice, int channel)
{
    auto slicedTensorTwoDim = slicedTensor->flat_inner_dims<float, 2>();
    slicedTensorTwoDim.chip<1>(channel).device(d) = tensorToSlice.tensor<float, 2>().chip<0>(0);
}

template void copyInputTensorsToOutputTensors(const GPUDevice& d, const float* inTensor, size_t count, float* outTensor);
template int8 copyLiteralToHost<int8>(const GPUDevice&, const int8* deviceValue);
template int32 copyLiteralToHost<int32>(const GPUDevice&, const int32* deviceValue);
template uint64 copyLiteralToHost<uint64>(const GPUDevice&, const uint64* deviceValue);
template double copyLiteralToHost<double>(const GPUDevice&, const double* deviceValue);
template bool copyLiteralToHost<bool>(const GPUDevice&, const bool* deviceValue);

#endif   // GOOGLE_CUDA