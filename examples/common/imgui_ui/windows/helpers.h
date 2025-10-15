/*
 *
 *    Copyright (c) 2023 Project CHIP Authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#include <app-common/zap-generated/attributes/Accessors.h>
#include <app-common/zap-generated/cluster-enums.h>
#include <app/data-model/Nullable.h>
#include <lib/core/Optional.h>

namespace example {
namespace Ui {
namespace Windows {

template <typename T, typename V>
void UpdateStateOptional(chip::EndpointId endpointId, chip::Optional<T> & targetValue, T & value,
                         chip::Protocols::InteractionModel::Status (*setter)(chip::EndpointId endpoint, V value),
                         chip::Protocols::InteractionModel::Status (*getter)(chip::EndpointId endpoint, V * value))
{
    if (targetValue.HasValue())
    {
        setter(endpointId, static_cast<V>(targetValue.Value()));
        targetValue.ClearValue();
    }
    V val;
    getter(endpointId, &val);
    value = static_cast<T>(val);
}

template <typename T, typename V>
void UpdateStateNullable(chip::EndpointId endpointId, chip::app::DataModel::Nullable<T> & targetValue, T & value,
                         chip::Protocols::InteractionModel::Status (*setter)(chip::EndpointId endpoint, V value),
                         chip::Protocols::InteractionModel::Status (*getter)(chip::EndpointId endpoint,
                                                                             chip::app::DataModel::Nullable<V> & value))
{
    // update model
    if (!targetValue.IsNull())
    {
        setter(endpointId, targetValue.Value());
        targetValue.SetNull();
    }

    // update ui
    chip::app::DataModel::Nullable<T> result{};
    getter(endpointId, result);
    value = result.Value();
}

template <typename T>
void UpdateStateEnum(chip::EndpointId endpointId, T & targetValue, T & value,
                     chip::Protocols::InteractionModel::Status (*setter)(chip::EndpointId endpoint, T value),
                     chip::Protocols::InteractionModel::Status (*getter)(chip::EndpointId endpoint, T * value))
{
    // Write to model if UI changed the value
    if (targetValue != value)
    {
        setter(endpointId, targetValue);
    }

    // Always read current value from model
    getter(endpointId, &value);
    targetValue = value;
}

template <typename T>
void UpdateStateReadOnly(chip::EndpointId endpointId, T & targetValue, T & value,
                         chip::Protocols::InteractionModel::Status (*getter)(chip::EndpointId endpoint, T * value))
{
    // Read-only attribute - only read from model
    getter(endpointId, &value);
    targetValue = value;
}

} // namespace Windows
} // namespace Ui
} // namespace example
