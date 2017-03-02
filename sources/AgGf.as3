// Emotion Fractal in AS3
// refer to http://levitated.net/daily/levEmotionFractal.html

package {
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.TextShortcuts;

	[SWF(backgroundColor="#000000", frameRate=30)] 

	public class EmotionFractal extends Sprite {

		private var queue:Array;
		private var words:Array;

		[Embed(systemFont="serif", fontName="font", unicodeRange="U+0041-U+005A", mimeType="application/x-font")]
		private var font:Class;

		public function EmotionFractal() {
			stage.align = "TL";
			stage.scaleMode = "noScale";

			words = 'Abandoned Abhor Ablaze Abominable Abrasive Absorbed Absurd Abused Abusive Accommodating Acknowledged Acquiescent Acrimonious Admonished Adoration Adored Adventurous Adverse Affected Affectionate Afflicted Affronted Afraid Aggravated Aggressive Agitated Agonized Agony Agreeable Airy Awkward Alienated Alive Alluring Alone Altruistic Ambiguous Ambitious Amenable Amorous Amused Anger Angry Anguished Animated Annoyed Anxiety Anxious Apathy Appealing Appeasing Appetizing Appreciation Apprehensive Ardent Arduous Argumentative  Armored Aroused Arrogant Astounded Attentive Avoidance Bemused Betrayed Bewildered Bewitched Bitchy Bitter Blah Blessed Blissful Blunt Boiling Bored Bothered Brave Breathless Breezy Bright Broken Bruised Buoyant Burdensome Bursting Callous Calm Captivated Captivating Careless Caring Celebrating Chagrined Charmed Charming Chastened Cheerful Cherishing Clandestine Clear Cold Collected Comatose Comfortable Compassion Competitive Complacent Composed Concerned Confused Congenial Content Cool Copasetic Coping Cordial Cornered Creative Crucified Crushed Cursed Cushy Cut down Dainty Defensive Dejected Delectable Delicate Delighted Demure Depressed Desirable Desired Desolate Despair Despondent Devoted Devoured Discomfort Discontented Disgust Dismal Dispassionate Displeased Disregard Disregarding Distracted Distressed Disturbed Doldrums Doomed Droopy Dull Eager Earnest Easy Ecstatic Electric Enchanted Endearing  Enduring Engaging Enjoy Enlivened Enraged Enraptured Enthused Enthusiastic Enticing Even tempered Exacerbated Exasperated Excited Exciting Exultation Fanatical Fascinated Fascinating Fear Fearful Fearing Fervent Fervor Fiery Flared up Flattering Flushed Flustered Fluttery Frantic Fretful Frigid Frisky Frustration Full Fuming Fun Funny Furious Galvanized Gay Genial Giggly Glad Glee Gleeful Gloom Gloomy Glowing Gnawing Good Goodness Grateful Gratified Gratitude Grave Grief Grieving Grim Griped Grounded Gushing Gusto Haggard Halfhearted Hardened Harsh Having Fun Hearty Heavy Hectic Hilarious Hopeful Hopeful Horrified Humorous Hurt Hysterical Impetuous Imposing Impressed Impressionable Impulsive Inattentive Indulged Indulgent Inept Infelicitous Inflexible Infuriated Insatiable Insensitive Insouciant Inspired Interested Intimidated Intrigued Inviting Irrepressible Irritated Irritation Jaunty Jealous Jittery Jolly Jovial Joy Joyful Jubilation Languid Languish Laugh Laughingly Lethargic Light hearted Lively Loathe Lonely Lonesome Lost Love Loved Loving Lukewarm Luxurious Mad Manic Martyr Meddlesome Melancholy Melodramatic Merry Mindful Mindless Mirthful Miserable Moderate Mopy Mortified Moved Nervous Nonchalant Not caring Numb Optimistic Overflowing Pain Panic Paralyzed Passionate Passive Patient Perky Perplexed Perturbation Perturbed Petrified Pine Piquant Pitied Placid Plagued Pleasant Pleasing Pleasurable Pleasured Pressured Protected Proud Provocative Provoked Quarrelsome Quenched Quiet Quivering Quivery Radiant Rash Raving Ravished Ravishing Ready to burst Receptive Reckless Reconciled Refreshed Rejected Rejection Rejoice Relish Repressed Repugnant Resentful Resentment Resigned Resistant Restrained Restraint Revived Ridiculous Romantic Rueful Safe Satiated Satisfaction Satisfied Scared Secretive Secure Sedate Seduced Seductive Seething Selfish Sensational Sensual Sentimental Serious Shaken Shielded Shocked Shutter Shy Silly Simmering Sincere Sinking Smug Snug Sober Sobering Soft Solemn Somber Sore Sorrow Sorrowful Sour Sparkling Spastic Spicy Spirited Spry Stoic Stranded Stressed Stricken Stung Stunned Subdued Subjugated Suffering Sunny Supportive Surrender Susceptible Suspended Sweet Sympathy Tame Tantalizing Tantrumy Temperate Tender Threatened Thrilled Tickled Tight Timid Tingly Tolerant Tormented Tortured Touched Tranquil Transported Trepidation Troubled Twitchy Uncomfortable Unconcerned Unconscious Uncontrollable Under pressure Undone Unfeeling Unhappy Unimpressed Unruffled Used Vexed Victim Victimized Vivacious Volcanic Voluptuous Vulnerable Warm Warmhearted Weary Welcomed Whining Winsome Wistful Woe Woeful Worked up Worried Wounded Wretched Yearn Yearning Yielding Zeal Zealous'.split(' ');

			TextShortcuts.init();
			init(null);
			addEventListener(MouseEvent.MOUSE_DOWN, init);
		}

		public function init(e:MouseEvent):void {
			Tweener.removeAllTweens();
			while (numChildren) removeChildAt(0);
			queue = [new Rectangle(0, 0, stage.stageWidth, stage.stageHeight)];
			addEventListener(Event.ENTER_FRAME, fill);
		}

		public function fill(e:Event):void {
			var i:int = 0;
			while (queue.length > 0 && i < 3) {
				var rect:Rectangle = queue.pop();
				if (rect.width > 2 && rect.height > 2) {
					fillRegion(rect);
					i++;
				}
			}
			if (!queue.length) removeEventListener(Event.ENTER_FRAME, fill);
		}

		public function fillRegion(region:Rectangle):void {
			var tf:TextField = new TextField();
			var fmt:TextFormat = new TextFormat();
			fmt.font = 'font';
			fmt.size = 24;
			fmt.letterSpacing = -0.4;
			fmt.rightMargin = 0.4;
			tf.defaultTextFormat = fmt;
			tf.text = choice(words).toUpperCase();
			tf.autoSize = "left";
			tf.embedFonts = true;
			tf.selectable = false;

			var bitmap:BitmapData = new BitmapData(tf.width, tf.height, true);
			bitmap.draw(tf);
			var bound:Rectangle = bitmap.getColorBoundsRect(0xFFFFFFFF, 0xFFFFFFFF, false);
			bitmap.dispose();

			var s:Number = region.width / bound.width * (Math.random() * 0.4 + 0.1);
			if (bound.height * s > region.height) s = region.height / bound.height;
			tf.scaleX = s;
			tf.scaleY = s;
			bound.x *= s;
			bound.y *= s;
			bound.width  *= s;
			bound.height *= s;

			switch (choice([1,2,3,4])) {
				case 1:
					tf.x = region.x - bound.x;
					tf.y = region.y - bound.y;
					queue.push(
						new Rectangle(region.x + bound.width, region.y, region.width - bound.width, bound.height),
						new Rectangle(region.x, region.y + bound.height, region.width, region.height - bound.height)
					);
					break;
				case 2:
					tf.x = region.x - bound.x;
					tf.y = region.bottom - bound.bottom;
					queue.push(
						new Rectangle(region.x + bound.width, region.bottom - bound.height, region.width - bound.width, bound.height),
						new Rectangle(region.x, region.y, region.width, region.height - bound.height)
					);
					break;
				case 3:
					tf.x = region.right - bound.right;
					tf.y = region.y - bound.y;
					queue.push(
						new Rectangle(region.x, region.y, region.width - bound.width, bound.height),
						new Rectangle(region.x, region.y + bound.height, region.width, region.height - bound.height)
					);
					break;
				case 4:
					tf.x = region.right - bound.right;
					tf.y = region.bottom - bound.bottom;
					queue.push(
						new Rectangle(region.x, region.bottom - bound.height, region.width - bound.width, bound.height),
						new Rectangle(region.x, region.y, region.width, region.height - bound.height)
					);
					break;
			}

			addChild(tf);
			Tweener.addTween(tf, {_text_color: 0xFFFFFF, time: 5, transition: "liner"});
		}

		private function choice(ary:Array):* {
			return ary[Math.floor(ary.length * Math.random())];
		}

	}
}
