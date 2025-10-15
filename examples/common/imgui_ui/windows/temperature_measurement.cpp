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
#include "temperature_measurement.h"
#include "helpers.h"

#include <imgui.h>

#include <math.h>

#include <app-common/zap-generated/attributes/Accessors.h>
#include <app-common/zap-generated/cluster-enums.h>

namespace example {
namespace Ui {
namespace Windows {

void TemperatureMeasurement::UpdateState()
{
    UpdateStateNullable(mEndpointId, mTargetTemperatureMeasurementValue, mTemperatureMeasurementValue,
                        &chip::app::Clusters::TemperatureMeasurement::Attributes::MeasuredValue::Set,
                        &chip::app::Clusters::TemperatureMeasurement::Attributes::MeasuredValue::Get);

    UpdateStateNullable(mEndpointId, mTargetTemperatureMeasurementMin, mTemperatureMeasurementMin,
                        &chip::app::Clusters::TemperatureMeasurement::Attributes::MinMeasuredValue::Set,
                        &chip::app::Clusters::TemperatureMeasurement::Attributes::MinMeasuredValue::Get);

    UpdateStateNullable(mEndpointId, mTargetTemperatureMeasurementMax, mTemperatureMeasurementMax,
                        &chip::app::Clusters::TemperatureMeasurement::Attributes::MaxMeasuredValue::Set,
                        &chip::app::Clusters::TemperatureMeasurement::Attributes::MaxMeasuredValue::Get);

    mTemperatureMeasurementTolerance = mTargetTemperatureMeasurementTolerance;
}

void TemperatureMeasurement::Render()
{
    ImGui::Begin(mTitle.c_str());
    ImGui::Text("On Endpoint %d", mEndpointId);

    int16_t temperatureValue = mTemperatureMeasurementValue;
    int16_t minValue         = mTemperatureMeasurementMin;
    int16_t maxValue         = mTemperatureMeasurementMax;
    uint16_t toleranceValue  = mTemperatureMeasurementTolerance;

    int uiValue     = temperatureValue;
    int uiMin       = minValue;
    int uiMax       = maxValue;
    int uiTolerance = toleranceValue;

    ImGui::LabelText("Relative Temperature Value", "%d", uiValue);
    if (temperatureValue != uiValue)
    {
        mTargetTemperatureMeasurementValue.Update(static_cast<int16_t>(temperatureValue));
    }

    ImGui::LabelText("Relative Temperature Min", "%d", uiMin);
    if (minValue != uiMin)
    {
        mTargetTemperatureMeasurementMin.Update(static_cast<int16_t>(minValue));
    }

    ImGui::LabelText("Relative Temperature Max", "%d", uiMax);
    if (maxValue != uiMax)
    {
        mTargetTemperatureMeasurementMax.Update(static_cast<int16_t>(maxValue));
    }

    ImGui::LabelText("Relative Temperature Tolerance", "%d", uiTolerance);
    if (toleranceValue != uiTolerance)
    {
        mTargetTemperatureMeasurementTolerance = toleranceValue;
    }

    ImGui::End();
}

} // namespace Windows
} // namespace Ui
} // namespace example
