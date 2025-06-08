/*
 * Copyright contributors to Besu.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
package org.hyperledger.besu.evm.precompile;

import org.hyperledger.besu.evm.frame.MessageFrame;
import org.hyperledger.besu.evm.gascalculator.GasCalculator;

import javax.annotation.Nonnull;

import org.apache.tuweni.bytes.Bytes;

/** The x precompiled contract. */
public class MLDSA65PrecompiledContract extends AbstractPrecompiledContract {
  // Load native library
  static {
    try {
      System.load(
          "/home/d1l1th1um/Desktop/Post-quantum-precompiled-contract-for-Besu/customized/libmldsa65.so");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load.\n" + e);
      System.exit(1);
    }
  }

  /**
   * Processes the given input with native code.
   *
   * @param input The input string to be processed.
   * @return The processed result from native code.
   */
  public native byte[] processWithNative(final byte[] input);

  /**
   * Instantiates a new MLDSAPrecompiledContract precompiled contract.
   *
   * @param gasCalculator the gas calculator
   */
  public MLDSA65PrecompiledContract(final GasCalculator gasCalculator) {
    super("MLDSA65", gasCalculator);
  }

  @Override
  public long gasRequirement(final Bytes input) {
    return 1;
  }

  @Nonnull
  @Override
  public PrecompileContractResult computePrecompile(
      final Bytes input, @Nonnull final MessageFrame messageFrame) {

    return PrecompileContractResult.success(
        Bytes.wrap(processWithNative(input.toArray()))); // .toArray to convert to byte[]
  }
}
