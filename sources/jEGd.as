// forked from checkmate's Checkmate Vol.6 Amatuer
package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	[SWF(width = "465", height = "465", backgroundColor = "0x000000", frameRate = "30")]
	
	public class FeelTheWind extends Sprite {
        private const STAGE_WIDTH:uint = 465;
        private const STAGE_HEIGHT:uint = 465;
        private const STAGE_CENTER_X:Number = STAGE_WIDTH * 0.5;
        private const STAGE_CENTER_Y:Number = STAGE_HEIGHT * 0.5;
		private var canvas:BitmapData;
		private var screen:Sprite;
		private var mtx3D:Matrix3D = new Matrix3D();
		private var projection:PerspectiveProjection;
		private var projectionMatrix3D:Matrix3D;
		private var skirt:Skirt = new Skirt();
		
		public function FeelTheWind() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			addChild( new Bitmap( canvas = new BitmapData( STAGE_WIDTH, STAGE_HEIGHT, true, 0xFF000000 ) ) );
			addChild( screen = new Sprite() );
			screen.alpha = 0;
			screen.x = STAGE_CENTER_X;
			screen.y = STAGE_CENTER_Y;
			projection = new PerspectiveProjection();
			projection.fieldOfView = 30;
			projectionMatrix3D = projection.toMatrix3D();
			addEventListener( Event.ENTER_FRAME, onEnterFrameHandler );
			addEventListener( Event.ENTER_FRAME,
				function( eventObject:Event ):void {
					if ( screen.alpha < 1 ) {
						screen.alpha += 0.04;
					} else {
						removeEventListener( Event.ENTER_FRAME, arguments.callee );
						start();
					}
				}
			);
			
			tf = new TextFormat();
			tf.font = "Verdana";
			tf.size = 12;
			scoreBoardDesign();
			gaugeDesign();
		}
		private var tf:TextFormat;
		private var score1st:TextField;
		private var score2nd:TextField;
		private var score3rd:TextField;
		private var scoreTotal:TextField;
		private var retryButton:Sprite;
		private var cullingButton:Sprite;
		private var windDirection:Sprite;
		private var windDirectionGauge:Sprite;
		private var windForceGauge:Sprite;
		private var forceGauge:Sprite;
		private var clickDirection:Sprite;
		private var clickForce:Sprite;
		private var resultBoard:Sprite;
		private var resultScore:TextField;
		private var resultGrade:TextField;
		private function scoreBoardDesign():void {
			var captionScore:TextField = new TextField();
			captionScore.autoSize = TextFieldAutoSize.LEFT;
			captionScore.x = 10;
			captionScore.y = 10;
			captionScore.selectable = false;
			captionScore.textColor = 0xFFFFFF;
			captionScore.defaultTextFormat = tf;
			captionScore.text = "SCORE";
			addChild( captionScore );
			
			cullingButton = new Sprite();
			//cullingButton.graphics.lineStyle( 1, 0x999900 )
			cullingButton.graphics.beginFill( 0x000000, 0 );			
			cullingButton.graphics.drawRect( -32, -12, 64, 24 );
			cullingButton.graphics.endFill();
			cullingButton.x = 32;
			cullingButton.y = 18;
			addChild( cullingButton );
			cullingButton.buttonMode = true;
			cullingButton.mouseChildren = false;
			cullingButton.addEventListener( MouseEvent.MOUSE_DOWN,
				function( eventObject:MouseEvent ):void {
					cullingFlag = !cullingFlag
				}
			);
			
			var cap1st:TextField = new TextField();
			cap1st.autoSize = TextFieldAutoSize.LEFT;
			cap1st.x = 20;
			cap1st.y = 30;
			cap1st.selectable = false;
			cap1st.textColor = 0xFFFFFF;
			cap1st.defaultTextFormat = tf;
			cap1st.text = "1st";
			addChild( cap1st );
			
			var cap2nd:TextField = new TextField();
			cap2nd.autoSize = TextFieldAutoSize.LEFT;
			cap2nd.x = 20;
			cap2nd.y = 50;
			cap2nd.selectable = false;
			cap2nd.textColor = 0xFFFFFF;
			cap2nd.defaultTextFormat = tf;
			cap2nd.text = "2nd";
			addChild( cap2nd );
			
			var cap3rd:TextField = new TextField();
			cap3rd.autoSize = TextFieldAutoSize.LEFT;
			cap3rd.x = 20;
			cap3rd.y = 70;
			cap3rd.selectable = false;
			cap3rd.textColor = 0xFFFFFF;
			cap3rd.defaultTextFormat = tf;
			cap3rd.text = "3rd";
			addChild( cap3rd );
			
			var capTotal:TextField = new TextField();
			capTotal.autoSize = TextFieldAutoSize.LEFT;
			capTotal.x = 20;
			capTotal.y = 90;
			capTotal.selectable = false;
			capTotal.textColor = 0xFFFFFF;
			capTotal.defaultTextFormat = tf;
			capTotal.text = "TOTAL";
			addChild( capTotal );
			
			
			score1st = new TextField();
			score1st.autoSize = TextFieldAutoSize.RIGHT;
			score1st.x = 120;
			score1st.y = 30;
			score1st.selectable = false;
			score1st.textColor = 0xFFFFFF;
			score1st.defaultTextFormat = tf;
			score1st.text = "0";
			addChild( score1st );
			
			score2nd = new TextField();
			score2nd.autoSize = TextFieldAutoSize.RIGHT;
			score2nd.x = 120;
			score2nd.y = 50;
			score2nd.selectable = false;
			score2nd.textColor = 0xFFFFFF;
			score2nd.defaultTextFormat = tf;
			score2nd.text = "0";
			addChild( score2nd );
			
			score3rd = new TextField();
			score3rd.autoSize = TextFieldAutoSize.RIGHT;
			score3rd.x = 120;
			score3rd.y = 70;
			score3rd.selectable = false;
			score3rd.textColor = 0xFFFFFF;
			score3rd.defaultTextFormat = tf;
			score3rd.text = "0";
			addChild( score3rd );
			
			scoreTotal = new TextField();
			scoreTotal.autoSize = TextFieldAutoSize.RIGHT;
			scoreTotal.x = 120;
			scoreTotal.y = 90;
			scoreTotal.selectable = false;
			scoreTotal.textColor = 0xFFFFFF;
			scoreTotal.defaultTextFormat = tf;
			scoreTotal.text = "0";
			addChild( scoreTotal );
			
			var capResult:TextField = new TextField();
			capResult.autoSize = TextFieldAutoSize.CENTER;
			capResult.x = 0;
			capResult.y = -45;
			capResult.selectable = false;
			capResult.textColor = 0xFFFF00;
			capResult.defaultTextFormat = tf;
			capResult.text = "RESULT";
			
			resultScore = new TextField();
			resultScore.autoSize = TextFieldAutoSize.CENTER;
			resultScore.x = 0;
			resultScore.y = -15;
			resultScore.selectable = false;
			resultScore.textColor = 0xFFFFFF;
			resultScore.defaultTextFormat = tf;
			resultScore.text = "SCORE";
			
			resultGrade = new TextField();
			resultGrade.autoSize = TextFieldAutoSize.CENTER;
			resultGrade.x = 0;
			resultGrade.y = 15;
			resultGrade.selectable = false;
			resultGrade.textColor = 0xFFFFFF;
			resultGrade.defaultTextFormat = tf;
			resultGrade.text = "GRADE";
			
			resultBoard = new Sprite();
			resultBoard.graphics.lineStyle( 1, 0x999900 )
			resultBoard.graphics.beginFill( 0x000000, 0.5 );			
			resultBoard.graphics.drawRect( -80, -50, 160, 100 );
			resultBoard.graphics.endFill();
			resultBoard.x = STAGE_CENTER_X;
			resultBoard.y = STAGE_CENTER_Y;
			addChild( resultBoard );
			resultBoard.addChild( capResult );
			resultBoard.addChild( resultScore );
			resultBoard.addChild( resultGrade );
			resultBoard.visible = false;
			
			var retry:TextField = new TextField();
			retry.autoSize = TextFieldAutoSize.CENTER;
			retry.x = 0;
			retry.y = -9;
			retry.selectable = false;
			retry.textColor = 0xFFFFFF;
			retry.defaultTextFormat = tf;
			retry.text = "RETRY";
			
			retryButton = new Sprite();
			retryButton.graphics.lineStyle( 1, 0x999900 )
			retryButton.graphics.beginFill( 0x000000, 0 );			
			retryButton.graphics.drawRect( -32, -12, 64, 24 );
			retryButton.graphics.endFill();
			retryButton.x = 420;
			retryButton.y = 30;
			addChild( retryButton );
			retryButton.addChild( retry );
			retryButton.visible = false;
			retryButton.buttonMode = true;
			retryButton.mouseChildren = false;
			retryButton.addEventListener( MouseEvent.MOUSE_DOWN, start );
		}
		private function gaugeDesign():void {
			var north:TextField = new TextField();
			north.autoSize = TextFieldAutoSize.CENTER;
			north.x = 158;
			north.y = 320;
			north.selectable = false;
			north.textColor = 0xFFFFFF;
			north.defaultTextFormat = tf;
			north.text = "N";
			addChild( north );
			
			addChild( windDirection = new Sprite() );
			windDirection.graphics.beginGradientFill( GradientType.LINEAR, [0x0000FF, 0xFFFFFF], [1, 1], [0x00, 0xFF] );
			windDirection.graphics.lineStyle( 1.0, 0xFFFFFF );
			windDirection.graphics.moveTo( 0, 0 );
			windDirection.graphics.lineTo( 10, 35 );
			windDirection.graphics.lineTo( 0, 30 );
			windDirection.graphics.lineTo( -10, 35 );
			windDirection.graphics.lineTo( 0, 0 );
			windDirection.x = 160;
			windDirection.y = 380;
			
			addChild( windDirectionGauge = new Sprite() );
			windDirectionGauge.graphics.lineStyle( 1.0, 0xFFFFFF );
			windDirectionGauge.graphics.drawCircle( 0, 0, 10 );
			windDirectionGauge.graphics.drawCircle( 0, 0, 30 );
			windDirectionGauge.graphics.moveTo( -40, 0 );
			windDirectionGauge.graphics.lineTo( 40, 0 );
			windDirectionGauge.graphics.moveTo( 0, -40 );
			windDirectionGauge.graphics.lineTo( 0, 40 );
			windDirectionGauge.x = 160;
			windDirectionGauge.y = 380;
			
			var forceBaseGauge:Sprite = new Sprite();
			forceBaseGauge.graphics.lineStyle( 1.0, 0xFFFFFF );
			forceBaseGauge.graphics.beginFill( 0xFF0000 );
			forceBaseGauge.graphics.drawRect( 0, 0, 100, 5 );
			forceBaseGauge.graphics.endFill();			
			forceBaseGauge.x = 260;
			forceBaseGauge.y = 380;
			addChild( forceBaseGauge );
			
			addChild( forceGauge = new Sprite() );
			forceGauge.graphics.lineStyle( 1.0, 0xFFFFFF );
			forceGauge.graphics.beginFill( 0xFFFF00 );
			forceGauge.graphics.drawRect( 0, 0, 100, 5 );
			forceGauge.graphics.endFill();			
			forceGauge.x = 260;
			forceGauge.y = 380;
			
			var capDirection:TextField = new TextField();
			capDirection.autoSize = TextFieldAutoSize.CENTER;
			capDirection.x = 160;
			capDirection.y = 430;
			capDirection.selectable = false;
			capDirection.textColor = 0xFFFFFF;
			capDirection.defaultTextFormat = tf;
			capDirection.text = "Direction";
			addChild( capDirection );
			
			var capForce:TextField = new TextField();
			capForce.autoSize = TextFieldAutoSize.CENTER;
			capForce.x = 310;
			capForce.y = 430;
			capForce.selectable = false;
			capForce.textColor = 0xFFFFFF;
			capForce.defaultTextFormat = tf;
			capForce.text = "Force";
			addChild( capForce );
			
			var capDirectClick:TextField = new TextField();
			capDirectClick.autoSize = TextFieldAutoSize.CENTER;
			capDirectClick.x = 0;
			capDirectClick.y = -90;
			capDirectClick.selectable = false;
			capDirectClick.textColor = 0xFFFF00;
			capDirectClick.defaultTextFormat = tf;
			capDirectClick.text = "CLICK";
			
			clickDirection = new Sprite();
			clickDirection.graphics.lineStyle( 1, 0x999900 )
			clickDirection.graphics.beginFill( 0x000000, 0 );			
			clickDirection.graphics.drawRect( -65, -70, 130, 140 );
			clickDirection.graphics.endFill();
			clickDirection.x = 160;
			clickDirection.y = 385;
			addChild( clickDirection );
			clickDirection.addChild( capDirectClick );
			clickDirection.visible = false;
			clickDirection.buttonMode = true;
			clickDirection.mouseChildren = false;
			clickDirection.addEventListener( MouseEvent.MOUSE_DOWN,
				function( eventObject:MouseEvent ):void {
					decisionDirection = true;
				}
			);
			
			var capForceClick:TextField = new TextField();
			capForceClick.autoSize = TextFieldAutoSize.CENTER;
			capForceClick.x = 0;
			capForceClick.y = -90;
			capForceClick.selectable = false;
			capForceClick.textColor = 0xFFFF00;
			capForceClick.defaultTextFormat = tf;
			capForceClick.text = "CLICK";
			
			clickForce = new Sprite();
			clickForce.graphics.lineStyle( 1, 0x999900 );
			clickForce.graphics.beginFill( 0x000000, 0 );			
			clickForce.graphics.drawRect( -65, -70, 130, 140 );
			clickForce.graphics.endFill();
			clickForce.x = 310;
			clickForce.y = 385;
			addChild( clickForce );
			clickForce.addChild( capForceClick );
			clickForce.visible = false;
			clickForce.buttonMode = true;
			clickForce.mouseChildren = false;
			clickForce.addEventListener( MouseEvent.MOUSE_DOWN,
				function( eventObject:MouseEvent ):void {
					decisionForce = true;
				}
			);
		}
		private var trying:uint;
		private var score:Array;
		private var decisionForce:Boolean;
		private var decisionDirection:Boolean;
		private var windFlag:Boolean;
		private var windDuration:int;
		private var windPower:Number;
		private var windPowerX:Number;
		private var windPowerY:Number;
		private var windPowerZ:Number;
		private var windDecrease:Number;
		private const DEGREE_TO_RADIAN:Number = Math.PI / 180;
		private function gameControl( eventObject:Event ):void {
			var windTrans:Function = function():void {
				var tmpDirect:Number = ( windDirection.rotation + 90 ) * DEGREE_TO_RADIAN;
				windPowerX = Math.cos( tmpDirect ) * -windPower;
				windPowerY = -windPower;
				windPowerZ = Math.sin( tmpDirect ) * windPower;
			}
			if ( windFlag ) {
				if ( windDuration >= 0 ) {
					windDuration -= 1;
				} else {
					if ( windPower > 0 ) {
						windTrans();
						windPower -= windDecrease;
					} else {
						windFlag = false;
						windPowerX = 0;
						windPowerY = 0;
						windPowerZ = 0;
						if ( trying < 3 ) {
							clickDirection.visible = true;
							clickForce.visible = true;
						}
					}
				}
			} else {
				if ( trying > 2 ) {
					removeEventListener( Event.ENTER_FRAME, gameControl );
					result();
				} else {
					if ( !decisionDirection ) {
						windDirection.rotation += 20;
					} else {
						clickDirection.visible = false;
					}
					if ( !decisionForce ) {
						forceGauge.scaleX += 0.08;
						if ( forceGauge.scaleX > 1.0 ) {
							forceGauge.scaleX = 0.04;
						}
					} else {
						clickForce.visible = false;
					}
					if ( decisionDirection && decisionForce ) {
						windPower = forceGauge.scaleX * 1.6 * 0.3;
						windTrans();
						score[ trying ] = int( ( ( 200 - Math.abs( windDirection.rotation ) ) * 0.1 ) * ( forceGauge.scaleX * 10 ) );
						scoreUpdate();
						windDecrease = windPower / 75;
						windDuration = 50;
						windFlag = true;
						decisionDirection = false;
						decisionForce = false;
						trying += 1;
					}
				}
			}
		}
		private function start( eventObject:MouseEvent = null ):void {
			resultBoard.visible = false;
			retryButton.visible = false;
			trying = 0;
			score = [ 0, 0, 0 ];
			scoreUpdate();
			decisionForce = false;
			decisionDirection = false;
			windFlag = false;
			windPowerX = 0;
			windPowerY = 0;
			windPowerZ = 0;
			clickDirection.visible = true;
			clickForce.visible = true;
			addEventListener( Event.ENTER_FRAME, gameControl );
		}
		private function scoreUpdate():void {
			score1st.text = score[ 0 ];
			score2nd.text = score[ 1 ];
			score3rd.text = score[ 2 ];
			scoreTotal.text = score[ 0 ] + score[ 1 ] + score[ 2 ];
		}
		private function result():void {
			var tmpScore:Number = score[ 0 ] + score[ 1 ] + score[ 2 ];
			resultScore.text = "SCORE : " + tmpScore;
			if ( tmpScore > 520 ) {
				resultGrade.text = "GRADE : EXCELLENT";
			} else if ( tmpScore > 420 ) {
				resultGrade.text = "GRADE : GREAT";
			} else if ( tmpScore > 300 ) {
				resultGrade.text = "GRADE : GOOD";
			} else if ( tmpScore > 150 ) {
				resultGrade.text = "GRADE : BAD";
			} else {
				resultGrade.text = "GRADE : POOR";
			}
			resultBoard.visible = true;
			retryButton.visible = true;
		}
		private var viewMoveX:Number = 0;
		private var viewMoveY:Number = 0;
		private var cullingFlag:Boolean = true;
		private function onEnterFrameHandler( eventObject:Event ):void {
			var projectedVerts:Vector.<Number> = new Vector.<Number>();
			var uvts:Vector.<Number> = new Vector.<Number>();
			var offsetZ:Number = 600;
			
			var cameraWorkX:Number = Math.sin( viewMoveX ) * 8;
			viewMoveX += 0.01;
			var cameraWorkY:Number = Math.sin( viewMoveY ) * 8 + 20;
			viewMoveY += 0.02;
			
			skirt.flutter( windPowerX, windPowerY, windPowerZ );
			
			mtx3D.identity();
			mtx3D.appendRotation( cameraWorkX, Vector3D.Y_AXIS);
			mtx3D.appendRotation( cameraWorkY, Vector3D.X_AXIS);
			mtx3D.appendTranslation( 0, 0, offsetZ );
			mtx3D.append( projectionMatrix3D );
			bugfix( mtx3D );
			
			Utils3D.projectVectors( mtx3D, skirt.vertices3D, projectedVerts, uvts );
			
			screen.graphics.clear();
			screen.graphics.lineStyle( 0, 0xFF0000 );
			//screen.graphics.beginFill( 0x993333 );
			if ( cullingFlag ) {
				screen.graphics.drawTriangles( projectedVerts, skirt.indices, null );
			} else {
				screen.graphics.drawTriangles( projectedVerts, skirt.indices, null, TriangleCulling.NEGATIVE );
			}
			//screen.graphics.endFill();
		}
		private function bugfix( matrix:Matrix3D ):void {
			var m1:Matrix3D = new Matrix3D(Vector.<Number>( [ 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 1, 0 ] ) );
			var m2:Matrix3D = new Matrix3D(Vector.<Number>( [ 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 1, 0, 0, 0, 0 ] ) );
			m1.append( m2 );
			if ( m1.rawData[15] == 20 ) {
				var rawData:Vector.<Number> = matrix.rawData;
				rawData[15] /= 20;
				matrix.rawData = rawData;
			}
		}
	}
}

class Skirt {
	public var flutter:Function;
	public var vertices3D:Vector.<Number>;
	public var indices:Vector.<int>;
	private var node:Array;
	public function Skirt() {
		var friction:Number = 0.8;
		var spring:Number = 0.04;
		var gravity:Number = 0.7;
		var rows:uint = 36;
		var cols:uint = 14;
		node = new Array( rows ).map(
			function():Array {
				return new Array( cols ).map(
					function():Object {
						return {
							px:0, py:0, pz:0,
							vx:0, vy:0, vz:0,
							mx:0, my:0, mz:0,
							fix:0
						};
					}
				);
			}
		);
		for ( var i:uint = 0; i < rows; i++ ) {
			for ( var j:uint = 0; j < cols; j++ ) {
				var radius:Number = 30 + ( j - 2 ) * 0.5;
				node[ i ][ j ].px = node[ i ][ j ].fx = Math.cos( i / rows * 6.24 ) * radius;
				node[ i ][ j ].py = node[ i ][ j ].fy = j * 1.75 - 50;
				node[ i ][ j ].pz = node[ i ][ j ].fz = Math.sin( i / rows * 6.24 ) * radius;
				
				if ( j < 2 ) {
					node[ i ][ j ].fix = 1;
					node[ i ][ j ].py = node[ i ][ j ].fy = j * 6 - 50;
				}
			}
		}
		indices = new Vector.<int>();
		for ( j = 0; j < cols - 1; j++ ) {
			for ( i = 0; i < rows; i++ ) {
				if( i != rows - 1 ) {
					indices.push( i + rows * j , i + rows * j + 1, i + rows * ( j + 1 ) );
					indices.push( i + 1 + ( rows * j ), i  + 1 + ( rows * ( j + 1 ) ),  i + ( rows * ( j + 1 ) ) );
				} else {
					indices.push( i + rows * j , rows * j, i + rows * ( j + 1 ) );
					indices.push( rows * j, rows * ( j + 1 ),  i + ( rows * ( j + 1 ) ) );
				}
			}
		}
		flutter = function( windPowerX:Number, windPowerY:Number, windPowerZ:Number ):void {
			vertices3D = new Vector.<Number>();
			for ( j = 0; j < cols; j++ ) {
				for ( i = 0; i < rows; i++ ) {
					node[ i ][ j ].mx = 0;
					node[ i ][ j ].my = 0;
					node[ i ][ j ].mz = 0;
					
					var bx:Number = node[ i ][ j ].px;
					var by:Number = node[ i ][ j ].py;
					var bz:Number = node[ i ][ j ].pz;
					if ( node[ i ][ j ].fix == 0 ) {
						node[ i ][ j ].px += node[ i ][ j - 1 ].mx;
						node[ i ][ j ].py += node[ i ][ j - 1 ].my;
						node[ i ][ j ].pz += node[ i ][ j - 1 ].mz;
						
						var vpx:Number = node[ i ][ j ].px + windPowerX + ( Math.random() * 0.4 - 0.2 );
						var vpy:Number = node[ i ][ j ].py + windPowerY + ( Math.random() * 0.4 - 0.2 );
						var vpz:Number = node[ i ][ j ].pz + windPowerZ + ( Math.random() * 0.4 - 0.2 );
						if ( vpx * vpx + vpz * vpz < 1600 ) {
							node[ i ][ j ].px = vpx;
							node[ i ][ j ].py = vpy;
							node[ i ][ j ].pz = vpz;
						}
						node[ i ][ j ].vx += ( node[ i ][ j - 1 ].px - node[ i ][ j ].px ) * spring;
						node[ i ][ j ].vy += ( node[ i ][ j - 1 ].py - node[ i ][ j ].py ) * spring;
						node[ i ][ j ].vz += ( node[ i ][ j - 1 ].pz - node[ i ][ j ].pz ) * spring;
						
						node[ i ][ j ].vx *= friction;
						node[ i ][ j ].vy *= friction;
						node[ i ][ j ].vz *= friction;
						
						node[ i ][ j ].px += node[ i ][ j ].vx;
						node[ i ][ j ].py += node[ i ][ j ].vy;
						node[ i ][ j ].pz += node[ i ][ j ].vz;
						
						var radius:Number = 0.5;
						node[ i ][ j ].px += Math.cos( i / rows * 6.24 ) * radius;
						node[ i ][ j ].py -= 0.08;
						node[ i ][ j ].pz += Math.sin( i / rows * 6.24 ) * radius;
						
						node[ i ][ j ].py += gravity;
					}
					node[ i ][ j ].mx = node[ i ][ j ].px - bx;
					node[ i ][ j ].my = node[ i ][ j ].py - by;
					node[ i ][ j ].mz = node[ i ][ j ].pz - bz;
					
					vertices3D.push( node[ i ][ j ].px, node[ i ][ j ].py, node[ i ][ j ].pz );
				}
			}
		}
	}
}