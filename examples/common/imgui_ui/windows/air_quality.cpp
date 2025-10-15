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
#include "air_quality.h"
#include "helpers.h"

#include <imgui.h>

#include <math.h>

#include <app-common/zap-generated/attributes/Accessors.h>
#include <app-common/zap-generated/cluster-enums.h>

namespace example {
namespace Ui {
namespace Windows {

static constexpr const char * GetAirQualityValueString(chip::app::Clusters::AirQuality::AirQualityEnum quality)
{
    switch (quality)
    {
    case chip::app::Clusters::AirQuality::AirQualityEnum::kGood:
        return "Good";
    case chip::app::Clusters::AirQuality::AirQualityEnum::kFair:
        return "Fair";
    case chip::app::Clusters::AirQuality::AirQualityEnum::kModerate:
        return "Moderate";
    case chip::app::Clusters::AirQuality::AirQualityEnum::kPoor:
        return "Poor";
    case chip::app::Clusters::AirQuality::AirQualityEnum::kVeryPoor:
        return "Very poor";
    case chip::app::Clusters::AirQuality::AirQualityEnum::kExtremelyPoor:
        return "Extremely poor";
    default:
        break;
    }

    return "unknown";
}

void AirQuality::UpdateState()
{
    UpdateStateEnum(mEndpointId, mTargetAirQuality, mAirQuality,
                    &chip::app::Clusters::AirQuality::Attributes::AirQuality::Set,
                    &chip::app::Clusters::AirQuality::Attributes::AirQuality::Get);
}

void AirQuality::Render()
{
    ImGui::Begin(mTitle.c_str());
    ImGui::Text("On Endpoint %d", mEndpointId);

    auto airQuality  = mAirQuality;
    int uiAirQuality = static_cast<int>(airQuality);
    ImGui::LabelText("Air Quality Value", "%s",
                     GetAirQualityValueString(static_cast<chip::app::Clusters::AirQuality::AirQualityEnum>(uiAirQuality)));

    if (uiAirQuality != static_cast<int>(airQuality))
    {
        mTargetAirQuality = static_cast<chip::app::Clusters::AirQuality::AirQualityEnum>(uiAirQuality);
    }

    ImGui::End();
}

} // namespace Windows
} // namespace Ui
} // namespace example
