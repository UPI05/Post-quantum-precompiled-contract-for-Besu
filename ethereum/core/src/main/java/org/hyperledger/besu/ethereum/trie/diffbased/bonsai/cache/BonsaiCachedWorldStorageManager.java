/*
 * Copyright Hyperledger Besu Contributors.
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
package org.hyperledger.besu.ethereum.trie.diffbased.bonsai.cache;

import org.hyperledger.besu.ethereum.trie.diffbased.bonsai.BonsaiWorldStateProvider;
import org.hyperledger.besu.ethereum.trie.diffbased.bonsai.storage.BonsaiSnapshotWorldStateKeyValueStorage;
import org.hyperledger.besu.ethereum.trie.diffbased.bonsai.storage.BonsaiWorldStateKeyValueStorage;
import org.hyperledger.besu.ethereum.trie.diffbased.bonsai.storage.BonsaiWorldStateLayerStorage;
import org.hyperledger.besu.ethereum.trie.diffbased.bonsai.worldview.BonsaiWorldState;
import org.hyperledger.besu.ethereum.trie.diffbased.common.cache.DiffBasedCachedWorldStorageManager;
import org.hyperledger.besu.ethereum.trie.diffbased.common.storage.DiffBasedWorldStateKeyValueStorage;
import org.hyperledger.besu.ethereum.trie.diffbased.common.worldview.DiffBasedWorldState;
import org.hyperledger.besu.evm.internal.EvmConfiguration;
import org.hyperledger.besu.metrics.ObservableMetricsSystem;

public class BonsaiCachedWorldStorageManager extends DiffBasedCachedWorldStorageManager {

  public BonsaiCachedWorldStorageManager(
      final BonsaiWorldStateProvider archive,
      final DiffBasedWorldStateKeyValueStorage worldStateKeyValueStorage,
      final ObservableMetricsSystem metricsSystem) {
    super(archive, worldStateKeyValueStorage, metricsSystem);
  }

  @Override
  public DiffBasedWorldState<?> createWorldState(
      final BonsaiWorldStateProvider archive,
      final DiffBasedWorldStateKeyValueStorage worldStateKeyValueStorage,
      final EvmConfiguration evmConfiguration) {
    return new BonsaiWorldState(
        archive, (BonsaiWorldStateKeyValueStorage) worldStateKeyValueStorage, evmConfiguration);
  }

  @Override
  public DiffBasedWorldStateKeyValueStorage createLayeredKeyValueStorage(
      final DiffBasedWorldStateKeyValueStorage worldStateKeyValueStorage) {
    return new BonsaiWorldStateLayerStorage(
        (BonsaiWorldStateKeyValueStorage) worldStateKeyValueStorage);
  }

  @Override
  public DiffBasedWorldStateKeyValueStorage createSnapshotKeyValueStorage(
      final DiffBasedWorldStateKeyValueStorage worldStateKeyValueStorage,
      final ObservableMetricsSystem metricsSystem) {
    return new BonsaiSnapshotWorldStateKeyValueStorage(
        (BonsaiWorldStateKeyValueStorage) worldStateKeyValueStorage, metricsSystem);
  }
}
