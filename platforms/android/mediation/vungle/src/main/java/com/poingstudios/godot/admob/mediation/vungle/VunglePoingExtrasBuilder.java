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

import android.os.Bundle;
import android.util.Log;

import com.google.ads.mediation.vungle.VungleConstants;
import com.google.android.gms.ads.mediation.MediationExtrasReceiver;

import java.util.Map;

/** Builds the Bundle consumed by the Google Mobile Ads Vungle adapters. */
public abstract class VunglePoingExtrasBuilder {
    private static final String USER_ID_KEY = "USER_ID_KEY";

    public abstract Class<? extends MediationExtrasReceiver> getAdapterClass();

    public Bundle buildExtras(Map<String, Object> extras) {
        Bundle bundle = new Bundle();
        if (extras != null) {
            Object userId = extras.get(USER_ID_KEY);
            if (userId != null) {
                bundle.putString(VungleConstants.KEY_USER_ID, (String) userId);
            }
        }

        Log.d("poing-godot-admob", "buildExtras of class: " + getAdapterClass());
        return bundle;
    }
}
