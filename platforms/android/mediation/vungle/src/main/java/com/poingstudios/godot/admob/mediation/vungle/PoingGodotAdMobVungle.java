// MIT License
//
// Copyright (c) 2023-present Poing Studios
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

package com.poingstudios.godot.admob.mediation.vungle;

import com.vungle.ads.VunglePrivacySettings;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;

import java.util.Arrays;
import java.util.List;

/** Godot 3 Android Plugin v1 entry point for the Vungle adapter. */
@SuppressWarnings("unused")
public class PoingGodotAdMobVungle extends GodotPlugin {
    public PoingGodotAdMobVungle(Godot godot) {
        super(godot);
    }

    @Override
    public String getPluginName() {
        return "PoingGodotAdMobVungle";
    }

    @Override
    public List<String> getPluginMethods() {
        return Arrays.asList("update_consent_status", "update_ccpa_status");
    }

    public void update_consent_status(int status, String consentMessageVersion) {
        VunglePrivacySettings.setGDPRStatus(status == 1, consentMessageVersion);
    }

    public void update_ccpa_status(int status) {
        VunglePrivacySettings.setCCPAStatus(status == 1);
    }
}
