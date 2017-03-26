package  {
	import com.bit101.components.ComboBox;
	import com.bit101.components.Label;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * Ho fast do we need to go ?
	 * @author makc
	 */
	[SWF(width="465", height="465")]
	public class SpaceTravel extends Sprite {
		// meter definition, SI 2.1.1.1
		public const c:Number = 299792458;
		// astonomical unit, IAU 2012 resolution B2
		public const au:Number = 149597870700;
		// light year
		public const ly:Number = c * 24 * 60 * 60 * 365.25;
		
		public var distance:ComboBox;
		public var time:ComboBox;
		public var fraction:Label;
		
		public function SpaceTravel () {
			new Label (this, 60, 150, "To reach the" +
				"                                    " +
			"in" +
				"                                    " +
			"you need to go at");
			
			with (distance = new ComboBox (this, 120, 150, "", [
				{
					label: "Sun",
					value: au
				},{
					label: "Jupiter",
					value: (5.204267 - 1) * au
				},{
					label: "Pluto",
					value: (39.264 - 1) * au
				},{
					label: "Proxima Centauri",
					value: 4.24 * ly
				},{
					label: "Sirius",
					value: 8.6 * ly
				},{
					label: "Galactic Center",
					value: 27000 * ly
				},{
					label: "nearest galaxy",
					value: 180000 * ly // actually Magellanic Clouds periapsis
				}
			])) {
				selectedIndex = 0; numVisibleItems = items.length;
				addEventListener (Event.SELECT, update);
			}
			
			with (time = new ComboBox (this, 236, 150, "", [
				{
					label: "ten years",
					value: 10 * 365.25 * 24 * 60 * 60
				},{
					label: "a year",
					value: 365.25 * 24 * 60 * 60 // julian year
				},{
					label: "three months",
					value: 0.25 * 365.25 * 24 * 60 * 60
				},{
					label: "two weeks",
					value: 14 * 24 * 60 * 60
				}
			])) {
				selectedIndex = 1; numVisibleItems = items.length;
				addEventListener (Event.SELECT, update);
			}
			
			with (fraction = new Label (this, 0, 180, "")) {
				scaleX = 4; scaleY = 4;
			}
			
			new Label (this, 90, 300, "(our current record of 0.000234 c is held by Helios 2 probe)");
			
			update ();
		}
		
		public function update (...whatever):void {
			var f:String = calculateFraction (
				time.selectedItem.value,
				distance.selectedItem.value
			).toString ();
			
			var i:int = 3, c:String = f.charAt (2);
			while ((i < f.length) && (f.charAt (i) == c)) i++;
			
			f = f.substr (0, i + 2);
			while (f.charAt (f.length - 1) == "0") f = f.substr (0, f.length - 1);
			
			fraction.text = f + " c";
			fraction.x = 230 - 11 * fraction.text.length;
		}
		
		public function calculateFraction (seconds:Number, meters:Number):Number {
			// seconds (here) = meters (here) / (c * fraction), but
			// seconds (on board) = meters (here) * sqrt (1 - fraction ^ 2) / (c * fraction)
			var fu:Number = c * seconds / meters;
			return Math.sqrt (1 / (1 + fu * fu));
		}
	}
}