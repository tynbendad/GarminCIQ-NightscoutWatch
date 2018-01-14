/*
 * NightscoutWatch Garmin Connect IQ watchface
 * Copyright (C) 2017 tynbendad@gmail.com
 * #WeAreNotWaiting
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, version 3 of the License.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   A copy of the GNU General Public License is available at
 *   https://www.gnu.org/licenses/gpl-3.0.txt
 */

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Calendar;

class bgwfView extends Ui.WatchFace {

	var width,height;

    function initialize() {
        WatchFace.initialize();
        
        //read last values from the Object Store
        var temp=App.getApp().getProperty(OSDATA);
        if(temp!=null) {bgdata=temp;}
        
        var now=Sys.getClockTime();
    	var ts=now.hour+":"+now.min.format("%02d");
        Sys.println("From OS: data="+bgdata+" elapsedMinutesMin="+elapsedMinutesMin+" at "+ts);        
    }

    // Load your resources here
    function onLayout(dc) {
        width=dc.getWidth();
        height=dc.getHeight();
        Sys.println("width:"+width+", height:"+height);
     }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Get and show the current time
        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);
        var dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.month, info.day]);
		var mySettings = Sys.getDeviceSettings();
		var clockMode = mySettings.is24Hour;
        var timeString;

        if (clockMode) {
        	timeString = Lang.format("$1$:$2$", [info.hour, info.min.format("%02d")]);
		} else {
			var hour = info.hour % 12;
			if (hour == 0) {
				hour = 12;
			}
			var ampm = "PM";
			if (info.hour < 12) {
				ampm = "AM";
			}
        	//timeString = Lang.format("$1$:$2$ $3$", [hour, info.min.format("%02d"), ampm]);
        	timeString = Lang.format("$1$:$2$", [hour, info.min.format("%02d")]);
		}

		dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_WHITE,Gfx.COLOR_TRANSPARENT);

		var dateLine, timeLine, miscLine, elapsedLine, directionLine, bgLine;
/*		dateLine = 25;
		timeLine = 50;
		miscLine = 80;
		elapsedLine = 105;
		directionLine = 130;
		bgLine = 155;
*/
		if ((width == 148) && (height == 205)) {
			// vivoactiveHR
			dateLine = 5;
			timeLine = 20;
			miscLine = 85;
			elapsedLine = 110;
			directionLine = 135;
			bgLine = 150;
		} else if ((width == 215) && (height == 180)) {
			// fr735xt
			dateLine = 5;
			timeLine = 12;
			miscLine = 75;
			elapsedLine = 92;
			directionLine = 109;
			bgLine = 120;
		} else {
			// (240,240) fenix 5/5x, fr935, vivoactive3, (218,218) fenix 5s/chronos
			dateLine = 5;
			timeLine = 33;
			miscLine = 88;
			elapsedLine = 113;
			directionLine = 138;
			bgLine = 165;
		}

		dc.drawText(width/2,dateLine,Gfx.FONT_SMALL,dateStr,Gfx.TEXT_JUSTIFY_CENTER);

		dc.drawText(width/2,timeLine,Gfx.FONT_NUMBER_HOT,timeString,Gfx.TEXT_JUSTIFY_CENTER);

		if (!canDoBG) {
			dc.drawText(width/2,miscLine,Gfx.FONT_SMALL,"Device unsupported",Gfx.TEXT_JUSTIFY_CENTER);
		} else if (setupReqd) {
			dc.drawText(width/2,miscLine,Gfx.FONT_SMALL,"Setup required",Gfx.TEXT_JUSTIFY_CENTER);
		} else if (!cgmSynced) {
			dc.drawText(width/2,miscLine,Gfx.FONT_SMALL,"CGM-sync="+syncCounter,Gfx.TEXT_JUSTIFY_CENTER);
		} else {
			if ((bgdata != null) &&
				bgdata.hasKey("rawbg")) {
				dc.drawText(width/2,miscLine,Gfx.FONT_SMALL,bgdata["rawbg"],Gfx.TEXT_JUSTIFY_CENTER);
			}
		}

		if ((bgdata != null) &&
			bgdata.hasKey("elapsedMills")) {
			var elapsedMills = bgdata["elapsedMills"];
	        var myMoment = new Time.Moment(elapsedMills / 1000);
			var elapsedMinutes = Math.floor(Time.now().subtract(myMoment).value() / 60);
	        var elapsed = elapsedMinutes.format("%d") + ((elapsedMinutes == 1) ? " min ago" : " mins ago");
	        if ((elapsedMinutes > 9999) || (elapsedMinutes < -999)) {
	        	elapsed = "";
	        }
	
			dc.drawText(width/2,elapsedLine,Gfx.FONT_SMALL,elapsed,Gfx.TEXT_JUSTIFY_CENTER);
		}

		if ((bgdata != null) &&
			bgdata.hasKey("direction") &&
			bgdata.hasKey("delta")) {
			dc.drawText(width/2,directionLine,Gfx.FONT_SMALL,
						bgdata["delta"] + " " + bgdata["direction"],
						Gfx.TEXT_JUSTIFY_CENTER);
		}

		if ((bgdata != null) &&
			bgdata.hasKey("bg")) {
			dc.drawText(width/2,bgLine,Gfx.FONT_NUMBER_HOT,bgdata["bg"].toString(),Gfx.TEXT_JUSTIFY_CENTER);
		}
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	var now=Sys.getClockTime();
    	var ts=now.hour+":"+now.min.format("%02d");        
        Sys.println("onHide elapsedMinutesMin="+elapsedMinutesMin+" "+ts);    
    	//now done in sync code: App.getApp().setProperty(OSMINUTESMIN, elapsedMinutesMin);    
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
