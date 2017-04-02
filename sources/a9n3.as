// Another Alternativa3D maze (textured :)
// use WASD + mouse to fly around
package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;

	import alternativ5.engine3d.controllers.*
	import alternativ5.engine3d.core.*
	import alternativ5.engine3d.display.*
	import alternativ5.engine3d.materials.*
	import alternativ5.engine3d.primitives.*
	import alternativ5.types.*

	[SWF(backgroundColor="0")]	
	public class Maze extends Sprite
	{
		private var maze:Array;
		private var SIZE:int = 11;
		private var N:int = 3; // don't go crazy :)

		private var q:int;

		private var texture2:BitmapData;
		private var texture3:BitmapData;

		public function Maze()
		{
			var image2:String = "";
			image2 += "/9j/4AAQSkZJRgABAgAAZABkAAD/7AARRHVja3kAAQAEAAAAQwAA/+4ADkFkb2JlAGTAAAAAAf/bAIQABQMDAwMDBQMDBQcEBAQHCAYFBQYICQcHCAcHCQsJCgoKCgkLCwwMDAwMCw4ODg4ODhQUFBQUFhYWFhYWFhYWFgEFBQUJCAkRCwsRFA8ODxQWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYW/8AAEQgAZABkAwERAAIRAQMRAf/EAKcAAAIDAQEBAAAAAAAAAAAA";
			image2 += "AAQFAQMGAgAIAQADAQEBAAAAAAAAAAAAAAACAwQBAAUQAAIBAgQEAwMHCQQLAAAAAAIDEgEEABEiEyEyFAUxQiNSMxVBUWGBcoIW8HFiokMkNAYXksJTJZGhwbLi8sNEZDVFEQACAgEDAgIHCAEFAAAAAAAAARECEiExAyIT8BRBUYHB8TIEYXGRoUJigiPC4VLyQxX/2gAMAwEAAhEDEQA/APl/t+zcLBlwJbSTyOO0sqCMaVOnokVdVdUvs+XEthsB5W4bzRJ1ZrESCOwKTEjlnVezlSPsR5dOnGVZ2Qw6ftbk";
			image2 += "tJOoVgIxILPSKPTpWo1tKZ50rGY8xailjsgLFS0pGFvcC0QYqe0IWjLuIyoMmdN/xY7MBII2bMRIbUdsXE027pWhMIRWTaR/c/TIB/tFUY8KDjpCrEjAbi42TuLoiSTjviSaikvfSu0qVBQvbiS6s3NZ6/2ngWfSM5LJoqcx3xgrpYGIrMBtzI7Zwjs66UbXpNk/HkNUSro9nAZaibXrOg57b23tbBErh15tiogzBqv2JEFKlRloZr8AAllqwbtodbmUalae02o2ppFrxMdcxfbEJctK5LKzKQZ1Lm4Vj7Q4Guxv";
			image2 += "dVk9RUXUd0vnMcLbVXbykoLUkIYPpqCRFS3YRGRHMvLq8uFofw8jompgMd/Jwu7hK3EhoNyQrMgs2ZKOTxZWlLQQuOWcfZEvLgsdRq+sd05tp6oLK9ns7C0qm2adyilFi9Ki7YslvYRmtTWsVwk0SkPKsefSQie0ahmc1adNrPFfiYz1PxHs7OuXTwiM+WXN03/Tl9OAhYnTxzMaer/UB7eNxaJa5NJGsTHVIpSPw4fZl9r8+GWck2QxcS0rc63EmbcoOkRFFpDlLzU10+9jKs6JJZcEyGgYrFcAElrGIsHOtK0E";
			image2 += "sdBzGAsYtYX1sG5VcjaowbuKWQllGizDPjIOcC9jzR2EHWpKr64t+1n1Aim5YppBkQr9OIcS2oUCZCZCvlGJebiXBKYJHuQ2dmonG23V1V4pRlKLRJdmbONCqVSV70PtD823jmKVm2dMure1c4bq2fK3JZtFrWM2ljM6yUAKOBeSRjXkLlwLrqZXjtGg0T3KxSTl2ZXSzH1poJ+4SClItwwDMRKuoTIJF846sMddDqzOof8AHGbw3HSgtbClEhYlbRWPqVJBmTD18kRjPRz6R5LQ21KrZHFjedtRbjcsULCuwGpG";
			image2 += "2zuXIAlqUGS/ckTKrXu+9GNGQyGGAS1F/UUtnCQVTulwy+EVldOtWAzKy6O8srBqVlvktypCLjBVOTlKEI8dfNOSh81qrpri/VMifuP842gdzpYNtnpzYBl+71BjJ8WLqDKBTcLTnKlf1RwutHidbkyurY6/eIt4fx/GLNiW7DcVvy2v8SUeXVz8uDhYi8nEzqLe2luWoCkyWDCMSiXpyIz8M8tHJ+bHci1CXpDWMTILgdpm5JRSERmkfGo/JSWZRjrHlwU6Br0F3b7UWXhdRPdIgggR2ykRDHkieVcx8v6UcDIK";
			image2 += "rqGHYWtKNZWFy0QzHfBkGVVKsqiZlCEfOcub7QbJvHXqJvu0st7G4LlVboaJEQkLvQjTL1IwKTgEwjzF+lgfQMsxdYudY9zsu4LPeJ15fgqhiRFLatgqVaUpUPu/N9WG1+Un5bMf24jfJSRW9s5VqYiNoa1DusX72q/SXQhKAyVpYOmMhDcE0xafqOxK6s2Ha2rwSLrYUOaOwhZ7phcVzXUqkHJSmiPLAsuIiFmBbk9YZa3TLofUUKRWQkZmKiFaWLKqKM0U1VpkAAfgOZfYB3E1uySldWN12vtchUJEpwEahatj";
			image2 += "WDqrU46pByjrwLKqaiN4laXBdwZJzStu4CTloBTKkVjeZb23Ql1LRr8xDQsDTUNy6wBd0uLfrFdytT3LgQE6EQl7xqK550qR+GE1eodKN1gz22Xx+O6HUwllEvebXLn4cv3cVf8AX49ZmK2Oe2ixlmJCJE12kVRkspGefj4Fx04Pl3OXoGzrcr4j2xIhEuFYrkwVjnw5eUa+XCWw16RlY9rumCbmA249VUrgCKUZadrMSqUiPRp+jmqIl0m8b1DI3F0kWLAhIkEaSQRCIkKxyGm0MfeUGesSlzFjpNT6gq47fdWp";
			image2 += "OIgJjUoiRlZiW2slGC2VJgCAjPQoxkemfmpgnsMVk0IbxJqr21NFRdS87nSpGsdUba2rXPLnz1af+UTp8pLaybG3bSlArjfG7EiA6AwhXuC3KNK0UTV+cj0bn3+ONTJ19gXt3Rd0U5JGxTABRNaMmPJgzoRIoM6+MYzkIR5vMFmBak7hHZ/WvjG3LSkGiRi0hgIqzkoWSD1chmRBUKc3zYUzrXRzdXDii7dkW0NvahIiitbTruDU9Xy+fmzwGY/i1MX307p120Cqygq6rjWo0kZJcTNQ+NPr4jhvF4/IrrGEnrq3";
			image2 += "ddFV0WlIQziJFqJa65Z8NMS+6OnCVozuHkW4s3P843No/wCDnsR83S+H2Y6sVR0R43Fytw7t/brcnLEY0WVSqFWDbD6oDTPKdCzAqGPOI+wEzHixsDeslq7C3MrgU+ndqkqi2BbEG2RlMs9ulA2vaHy8vDAtnTKgZp7bZ2bi3JagEglbWhRKMCqVDCo0Ll1j5pFzjgc3Id7Vx2GViz+Tb7tiv/Yr/mMc5n0fb09vBayuJ1XQFVujM0gvXGnq7kpSHD+5WBKjLYlfYkyJNrJaLo2yJoWYiOyE6bdah6ZiqpFpoPiH";
			image2 += "liJIWpzvTHb8wS4tyO/tHWNuVqLLm+EwHaWM+ms1s26AenOsplMtPmlPBrQ7najRD7b7XbsFlvcCs0lA2mPpm5yiDebkUxMY7hyHb1VCZxpPW5ArVV0k8PZ129wd44eoVako1W+oRXIiOlRJvGIU5zhlQi5h8qbImtV1ex4WfDUtvGJVcWYqUKQbHbIlgRiQ1oeYxDnZOhUzywurZiUgncGLuGBeJERYxT2qaK9tklEB1Je5LLXTIDxlkir6d4mSvRi57rf1x/eCM1LHT6DzyMaBUa00lq9iXhxxtNT0MnGqOdq1";
			image2 += "ZeNRQwEWDQiMkW3MORiHhkHHTEY6eHhpxvcYfNWra0F3TWfxWOy/4XybsA3Zwz54R59Ofs/Jh2XRIvLq2Cu1Ouo1cseoYNYbRxavcJtdNBrn8ur8+rm1Y2zI8oUDvZd3BxyFrDZFCiKKxY6JRWXzMrHRQB1iMcpzwtnfLWQrtvfO5dqvLW6sqWbvhdw01W10gCcW4Ie8esQusuTaJVwJpZ6ittmvG1TgY7PEq/lu3oLrIhICAVaEEJMIdwSHhA6HUx8oh5fNjE1Op1JyNANmlKaO0DcuUahu1bRLYKxUhh+m04Ln";
			image2 += "UyBR6NOqgZiOGJYmct6qugBYt6UrAHbhUK87shw3VTWnZFFlU0toviVGCwqFtZHqEKcNODSyE8vO4C9y4t49LHqdhRARjKTBeVcnlUq0UAnUPH5RwqjkXxy0H3glY2Ydy/eZXiha24UzpCFySH1JRYghIGVFsgkZSMsvDG3R2afSUj3rtd4RWO0217jbgTTuBZvi/fLd9XIaQOTPTD5KlWh+JRBtC6qBJ37uF523uRiMVh0+0VrHcXL9ossioYwIPtYm5Eeh9NxZGZpu25St6yFa7pQmBCzMSU+mfhSsSnnqEcNq";
			image2 += "1JW/p7Kq1Oets6DQXLNgDGq9tNVGOilOBe1wE/y0lgxLay1Ytj++beRw3ctqHrbcM/zx+94YdPQZGu427UJAgxSZFbTqQ6ZFIDrzcf0J0wFxfHxtLUdWdnuXBdYr92YokXShEJEki5qTzoWrUovKUSx1WZFZCRStxBvXG41xhC4ISErl7IZbI+oxtakIAZgGnOWNxMrTqaQVY3DLHeXbgDNwPWaO6tPoCdBbSZS9GZcx05tXNgXYbGqQ1vis3Wt0xhjZgNqQ3CYsJgELCzEZlpkwz0c24XzFgrMDlr0iUrO6d3e1";
			image2 += "tVu3hXed1NWfqCRLsbQmNFVeB7u2VD8pebzY2rJuVwht2XqEssmCrZbbtESURq3LlyyOrSicaNAqzZyViXtDzbW+ou9Utj14PdLMlEwg3xEWqLdkWoii2tQOlBqSqBCFcvDC+SHaQK0nczxJZZ94F1uZ9SwRUIlEVsGOmVT0kMKfXiaSvjtlUq7h0LHfEO1VC6atEXGMSFTJj6m2zKg6/wAvNjZKeGukMHQDrdp3JVasrQbzafQJV3Rtbw6VIYkIMzER+fSRfJmJcdfH4FL5/UDFasYtO2Q78RawBl+0VWmZZfn/";
			image2 += "ACHAbCOfkd9xL0Nv1/Tz18uctUtvwz5f1vDFXceMiP07jLtESUCS/aerRShGJFv1qNcxIebUPNpHA3Zt1aRsN8m37pQnfxdqIy0RESGTK02jie5xkeMqF21Go8tFI7nfUuStzvn2DSYnaaSFWxFSpNYKhqDGFUv0eUcMyM4a4TZhq7G6KzLet9nbQ8ekV6axeSiYNeGmokVV1kH6shkGIK5srpjcbdyV3VwwRZeLG5aciKQ+g4CrVzIZ+B03JcfmZWOOsxsykZHuNxfN7rYWuW4/O+Otv9rt4UZwDaiTYSOUS5fn";
			image2 += "LG1JOevShlb3lqQuG1MWdwcUCuDJaViwSJ9G1IyoY5rn5M/vyxzvoT0q1uUMZb314i6ZuuXdCZcsRIhEsxpRUTERy05eNPZLmRaWpDtSdin+YE3VjY2/b4F01wZkTQaJFuJGFfGldyRUjPkjhdmiv6XiyuZlt4y3Zs7Q5WugamArMinXOVQoFTkPmPV93BV1PT5qxoim6vjZvkIDtF1BANJEUWW9zprwz0y5tOH8TIbvTQv2Rclm2JiwmqgwREvLnSkvaLT5cSu0Mo+kor7g+Vn+Kuny9CEMp+bpIyzhy/dw2X2Z";
			image2 += "8bjOjuxAHaTXZ0gBVPbryVL0gF40KtM6RizOOWfN9HjRdzbx6iVbIZJvrgby3K3u7hhpDQ3dKQiXAhVSJcKyLTqpzYTOhUtwmx71fMYd5bz3SaD67T2qFQk0W5KpU8w2zAajEs5CJeTA3k36Tjoq9Q37BcXDCrZ3VD2pMEgBr1iJbZG3boswH1akYMDw1VjHA1bF87St0Gm7exnch27q6eu2Wh4DutaTFktUBJRA2pHVoF6wMAttdT28vI6dCVfUWdmjJ3nw0e9rYLRvlBdXQk5Xpeoy39KYHUP2x+wIxHDZJuar";
			image2 += "txJDQVsXs3yRWkbf0haItZtkI5bXJwl+bCEjHxOvGpKidasWXcFqG1G3fG3NsfTZEgEa1nTURUIf4fTgLI6qq9yOlJdvdXV1cBedVMXR9KJSE+FNRbfChxDy+bCuRyUVh2TRnlJK4IiXqaIiYqjEgHzDlSvtFEfyjtanpfUc+LUi2tuwXst4GO2h+0qMmCLEH9Hs1+TFFbklrK1dg243LMXLZqFhS0iOqJZSH2h/VxMlLMrzYrYz28XW7mqMMofJ7j5s+T+7j0sVgL1xOV3MbCtvKtBA+A82ZUlqoP0Yx06pDWwc";
			image2 += "UVp5YtEhITlKC/73hp+vCKqWUrcstSEaAsaDcVSM1UAi94RfPw+Tyl+bGWTGWVdkazsvcLdNwqtur4jbjzsMQIfUhOvAhiEvUlOkcT2klxbUmpt+7WJLuGEbOuWppWjlSFMtozo1lQz0iwJn4+X3calV6epFerhWMg++2/5js7i3iNq4rwR3RHa2xEGDU8o/IQDI8o+bB11q2NvxWxr7R9auKxtyG3J6+oQCm3LVkUowqwaNoUfUPVAMxwm9zL1tbjUgtj3K66oRsWmxqyHpRuiWRPJxFTdo0ypQa7nk+XAKwlca";
			image2 += "T1BO/X11ddwN1wIMkMiENzmETpWkjhDKP9ocdiDSa1TRnLizZ1CmCZZFyUGWhah41zlWOcfy5cGrQj0n1JSW2VkSVXNwVRTRKLmdR0s9RRhkRHwlx5R4xn9rBJja2daF95Y3i7ebA0Mt1bVBjIRLjTLhnDVUtP0YnV9YM4ubL0CXbTl/5XupeWOxtx5so/d5cWZuANIEsd0AIRIiGQmXGukR4YsklVXOgyEDXbkTNJJOOZV9T5M6Vz9nIZez9eJmpZe/l1LFiCLet06nMO1VTazEj10rWQ8QjlpGuMtq4O476B9n";
			image2 += "R2XTi0V1ISMqNICHlrKtKUodJ/oxl9muEXGLjyHdjfCsqW91/DX0ioBEBKEmDBeeqmnOuiOBrWUyflo24fzEOtmXXfe3JZSVwxl5asTcD6qhFSFZ1UtYt3Z1OAVD2fJjU1jb2AXrhx09XUX3zLrt9qZKUTFpES0y0k8gqPp8BSTl1KvtfZwmDOLhrakHTnMZabwtKxNLVgJh6q1rGNRlQBGk+RZbkfZ9rDqOCbtVjFF3cr66upW94Y3z1zQ15ip0VSMxrwE5yItNJypgSvtVTcCl1vuCAsMmIcIkLRXqIhXlWOf0";
			image2 += "11Y7ETio1B7USvri+t2SYi3RdXQUER1FtVCk89UOPtYKqVUPrXpaOLi86hdbeArEROXLrJY0y4gPMX6uArWHIiuzFkP8yyyDbhPKAw5Pm+3h2Tw8esqz/rgm27Kyxq1zZbJDK1gfvWCVPmpLSNS8PNTxw23OrrQpX03b3A37bFga6yLIhyHVHwyLP/ZjeNQ9RPJ1bBFqshEViJCBEPMA6iEv9OeqOF8jMpSBmNsmTt+saTE10GBDQCAqVGhVOWJ7200KuGwdZuXeMyvKk65ICEgmAyXHKlKDXKTPY5tP2cZhhoAr";
			image2 += "Ll5NPmFVulncO92NJmW41+60dTBHQNSrl9H0/Xh+WNLP7gXwTgnt1GuX3QttV1bqBxpOdB9dyzWxhennzDVoVpI9JHAOI+ZNkIhRgit1x1V1cOJoDdLMyMlaRHVk2grodAGgyHIAppoWrHKRNqKm4FcXQu2eqGQiCx3RjuNSSyqVSrwmOnm/Wxr0DlZaBSelda9P3BpWpTtqW7jAmsESVTaptSg2tJcpcvlKnLhT5IZTwKrrqAdw7LeWLDFoUvDulXzkuDUo1CILq9JUyoQ8+fscfYwfHyTr9wzsYXxFJDdpYCWj";
			image2 += "FrtIKIoiLCGlKZ/MWCrFnCIfLOmoN8NH4P10+PVbMcx5trL/AH+H+vFPcU4/YN8v/VPjc1qd3bttvrdiZ9J0O/teNd3by9Pan92f6MsQ9Wswe105ARfhHqlfEviW1p6WecpT4RhrjzRhwz+vB17n6Y/IC/Yx6veED+AOo1be5Om5Lq857ny7enx9/wBPo/w/LgOXzM/t9nxN4fJ4/u/kEl/TvhvT67aGH8bu70S3dzLTu7keXhnt+SWAr5mf2+z4m83k4/d/ILT8HiHwze243U/4uWztN3d3qOHuYw29UeT1Mc+9";
			image2 += "7fYJp5eVjt7RfT8JZt+IdDvbzOk3N7pozZ1EfPHl2971MA+9P9cx6dv47+4q4+xCy941tf6XdQn4j8J6Pc9be+IS29O5t7fDP8qYZxd/xBJfy+XxGvZP6e7Zb+xtZhHpvj0p5l7ra+mcZ/XwxNfzM9P+JTxdjH4nm/gTfZ8T3YQ1db8c9/As97LVKO3ubfmhHRLA2814xKb+Xzc+8h39N5p6XPY88fxD7rbpGX7Tdh7PDbj5cA/Oz/wFcf8A5+Dn/MvR8M/zf32XQXU+o+JT+HbQ7ex1nqThyS08uWOfezWUZfx9";
			image2 += "2g59nHp+X2/EFuNqRfib8Ubuye/1ee1txrvb/Vep7qfjonng1nDjHL7Pv/D3mvCV/s8e0U/9/wD/AGviG7+h8Xluf2tiH3Nz6MUaz6Mfy+P5+0T+g//Z";

			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener ("complete", onImage2);
			loader.loadBytes (new Base64 (image2));
		}

		private function onImage2 (e:Event):void {
			texture2 = Bitmap (LoaderInfo(e.target).content).bitmapData;

			var image3:String = "";
			image3 += "/9j/4AAQSkZJRgABAgAAZABkAAD/7AARRHVja3kAAQAEAAAAFAAA/+4ADkFkb2JlAGTAAAAAAf/bAIQAEg4ODhAOFRAQFR4TERMeIxoVFRojIhgYGhgYIiceIiEhIh4nJy4wMzAuJz4+QUE+PkFBQUFBQUFBQUFBQUFBQQEUExMWGRYbFxcbGhYaFhohGh0dGiExISEkISExPi0nJycnLT44OzMzMzs4QUE+PkFBQUFBQUFBQUFBQUFBQUFB/8AAEQgAgACAAwEiAAIRAQMRAf/EAJUAAAIDAQEAAAAAAAAAAAAA";
			image3 += "AAQFAgMGAQABAQEBAQEAAAAAAAAAAAAAAAABAgMEEAACAQMDAQUECAYBBQEAAAABAgMAEQQhEgUxQVFhIhNxkTIUgaGxwdFCUiNicoIkFQaS8DNTNERFEQACAQMEAQIFAgcAAAAAAAAAAREhMQJBcYGRUWES8CJSgpJCE6GxwdHhYuL/2gAMAwEAAhEDEQA/AEMvkTcR0FyQPGqxlYYuCSbdARR0y+Uyyi8cY89vzAadKXGbirm0LC4/U2lc0qHoeTTpHJaudigdhtbqNbVcudhF7oo1/LagvU43T9trjxarY24s";
			image3 += "uo9Nr+BNWNzPuf8AqGzy4UIUuh82tUHMwCNBsJ7dWorkflV9IzKShHlHQ+8UuaTjb+VWUdouaEt45Lhm4Wwg6t2HpVkU2PPIqxi19DcXoRJePB8yll7rkURA+CzXhDIw6a3FKCXN+icmTjRMytr2XIFQTkMFCCVDeFeyDho+2cXk6mxNrH2VQZeLvcRm36bt9tRLc02/K5LTnYRcn4VJvYDpV8UkMwJj1A1JtpbpQhn4i4/Za3870x435CQt6EZU2ubsWuv00hE97pMPYp/yXHxL6Zj3EdSRreq25LC2FVUC41IG";
			image3 += "tDzScYZCVVlBOoJJqvdxvWzey5q9i6vit7lvzmOTa/l/68KLixt+OZ76bSQLdxtQBbjLiyMB26mnuIY2xCuOpUBSAG117aQiNvyuC3kFxooHmkIfeg8gP5T7KQCfiQdYW9l2p/JjpHx5yJ0Dx+mPL4A2pF6/EBtYGtbUBmtRev8AAO9K7kEk4ltxkDp+kKC321ck3DsdqQNv/KxZvfUFn4cSbmiYpbRLnr7alDPxe4bYCWvcXLdO6nYv9Iw5FsPZA+SC6keXabAWAudKX+rw1vge/wDMaZ8nJhII4siK6Eb4rEja";
			image3 += "pAve1LWm4ba22I3PwkM+lEGvVEfW4m/wNbuuaJw5eMaXyRtu8TpQ/rcRYARtfox3N76KwZeL3sVjZm/Lc9KBcHORl41ZrSISygAlSRcHpQDT8aSLRMO/VtaKzcnBMp9WC7DQWJH2UKJ+N0vEfZdqdjX9PJxpeNPwoV8LsaYcekUm75a6gi7sxNlX6aEE3EWuYreG570bxqJKkiwEKltz3J+G9Hsy474oXM/H3beGB6i16ircbcbgxHbYmrmm4r86MGOp2k2rom4O9zFJ7NxpG4b0+UiH4b/xuT/MRWi49YDjK0Y2";
			image3 += "xgNoT79az/rcLuFoWt2gs2tMo3b5VhCRHCfKsfVrHxo3BFjP+B1lpHBxlpx6qRx+df1C/Ssq2Vw1v/VIbwZ7fWa1eVk46ccZ5kLRsgvH33NZdsvhSw/tmQDrq7ffT4oWNvuBmm40sbRtt0sLtRCS8Q1gkJEh6eZtLVBcjiFbWIuL/m3fdXWn4h3tFj7G7Npa3ffWp2PFcWMuUkwxDjpkXbtRh1AsOtqWibhwPgcsDcG5F/CjMs4kUY+aT1d/mjsSCoHfag3yOIK2SFlPfuY0XxAfHJM5PCE6Quun6j+FEYcvEyuU";
			image3 += "jhIdtFZmPlvQvzfD7R+wxYdu5tathyMF3Hy0OyQ6AkkgX9tXsL7SrKfDilKSJvK9oJ191Difje2I+9r++j8+Tj4XEcsO6VQLtci9/ZQQyeNvf0T7PNTsk1/TyWjL4i2uJr/PJTHj8nCVZGx4jG9r3ZiwIHZ5qW/NcVYn5extYC8nXvqzEMUhIiU9Lnr99R08msUnR+0icjh9xMkDAnXRm7fCuDI4O2sL/wDJqqeXj9x3Ib/1V0y8SQoEbAj4jdjeidLMjSm+JaJ+Cv8A9lz/AFNTeHDTJhVsXyIB8Ld4PfShH4Wx";
			image3 += "urbh0B3C9OsbLWLHjEC7YlHmB69dQKr9RjrARMyDhi8q7kjUXX6bVnzm8Re3yug8XrTTCFOD/fAdRGHZF03C9utZwZnCLcNis39T2FFpsHrpXUqOZwxUj5YgntBbT31yGfivUF4S/b5iw6eyvHL4r1Awxjs7Uu2vjU2yuIkZRFilDfXVtffTsn4hnLDCjWFiu5ZAWUC+gFAxZPDrf1IDIT01ZdtNeVmwIooPmIDIGBMdiV2jTupWmXwtjvxm3dlma1vGkbiX4XJ5Mjhg12jZh2LdquxsjjpJwIINoOmpJINQOVwJ";
			image3 += "B/YdWPbubQ1PCnwmnC48RBJsGJJN6nZb/SV5+RijIdciLe6iysLj2UImRx4Hni3H+ofZR2dk4MeS8c0BkkXQvc3v9FCjK4vyg4zadTdrmrG5J2J/N8OP/lJP8zij+HycVXPpxEF766ny92tALlcQFYHGJJ+EkvdfrphwqYs037e5Co3a9tuoo+S4rYBkzOI9Rr4ptfpub7q6M3grebEN/B3qqSfjfUb9pgpJIFzca1MZfDX1xiR2+Zr07J+J55+DdgUhdDceXcxWni5OK3HejDERYEIOu3XU3pLJlcKwUR47RtfX";
			image3 += "Vjcd1O8VsRuPljiQqWQlWJ6MnZWcujWMapPYZ8i0UPAqGVXIjXeOh9PdrasovIcSpN8L1Ae8yC3ssa12XlYn+MMjKJvThvIn8BYC1ZJ+Q4c6DCKHvBf8asa/yJMUjXU7JyHBt5lwLG1tu6Tb7fbVCZHGO6hMYh++7W07aJXk+DFt2Bfv1f8AGuR5XEyy+TGCjsHm3Dxp2F9oXyjY8fojLHrjYXGuoJtoLe2lnzXEbT/bsp7CC1F582MgVZ13D4h4UGuXxVtYAD37morFyvdck5MzhnQBMdkcdTuY3oriZcBspBFE";
			image3 += "Q/QMSepoUZHENqU2kfxEUZxT4rZYOMgL67bnpp407Jf6SrlcrCTMkVse8g0ZtdfdQQyuPJucdvAC9H8jm4a5DibHWSVTYtrc+6hTn8Ywt8ntPhuq9ktShH5ri7a4z39rCmnE5mKGZoYdjGwsWJupNu0UrfM4xlAGKVIPUFrmisHIgMcixxBGNju1vYHxqOiNY1cUKZsziSz3xNrEkggv29thpVKZHFg+eIsO7zCprmcesm+SEsepQ7tp91c+b4slrwHab7V83lv4+FPyDvE4Ehk8OUAOOwk/WC1PcOMNhAxi0ZDL";
			image3 += "Y9d1IjlcOyBRjsr9NwLa3rQYLwDDvGpVQd1r9AND76mVi43dVwckzIosOQSR7/2QjKfhK36WpAMzjQ9zjWAb4QGtt7utPJ9qYLzSxB1EYIN+9ulqUNyfGF1JwFUL127/ADe25qK2prJqaQq1PTclwzLaPB2MO27fealhT8LLKDJE6sRfYrEAGqpOT4t3uMBUXsA3fjUosjiXYFYCkg1Chjb3Vrs5qv0l3IphwSBZ/MDqLG1l9tL/AFOIP5WA9p+qmucMCOJDmoWlcFlKnaLUs9bhifgYDxJq6a8BuXpyWpL/AK8Q";
			image3 += "A8UhI7d5F/qphxcnDLkhsdZA/RSzblBtr2UuWXgTbcjgD4vMdfZpUsZsIzf2+7U2AJvao6eS4qafKEZ+dgDJZnxg8jX3HXr4WoSHP49GLPiCTsCNfbb39aJysvDx5dr44lcCzXv91Djk8Ldf5JSO4hvxovNQ6NqUekz+Mdwy4KoO1Rv1+uisIxT+p8tBs0vbU7VHtoeTkuNdbDAEZ7xuv9tOuCysGUyiPHEBVNzWJ84HfejRE2qqBF85xyyXeAm3Ua2Jq4clwn5sH6AXoebLwWmZxBtDEnaN1ta4uXxw1aAt/D5r";
			image3 += "Utow664l8OdwwYmTEL3PlW7AAe2tLA2LLxORJjp6S/lTrbUaVmkz+IvZsHwFi9a3FTF/w0mVBH6YkjYCMm/wmjt/cJ1r6WI8icfExvW9H1oDEAQfhKHQVmP8jxSjTCuR0vut9tazkMqJuKnyJYg8CooWMn4rGxvWR/yfHAW+QXTts/40hRQS5rdUqUy52AZAyYu1Re62axv9NWwZPFOyf25Eg+IXYD3VJuU4tlA+QCkdSu6/1mvLmcVLKGTGMb/puwUW8KdlXj5QjlJcRWiTKjLRgEpYkMBStJuLud6kr2C56e2n";
			image3 += "HKSYMfpfOIzlhuWxtZfopZ8xwZBvHJcnQ3PlpG5J25Jib/XyBujk+hjRHHz8UuYJIUawPkBO6x8aHSX/AF/ed8chS2g3EG9W4Q4yXJCwFl3MAu65236daO2oxSnQI5fOwEzW/tvUk0LFr9o7hQA5PDvrgofob8aO5rIxMbOaNofVmCqHY31NuooCPk8NU2thq5P5iDu+2qHwVnMwib+gQOywNaL/AF+TFmWZo4PT9NbsdbuD2G9Iv8lhdmGB4+b8ac8PyeLHDII4PT3Wue1te29S3ktXSjE83Ica7kjC2C50BbWq";
			image3 += "0zONV7tjb1/Sd1XS8pgs7WwkFyT0f8agOS48dcJG/wCX41ezMv0JNyHEvdVwQhIsCC9we/rWy475Z+IUO/pwurBVP5bdbVi05DjvW3nDUqdPT820fXWoxcjFfBUxrsQOGWLrsTtqT8M0sZ/5Jz5mPBw5V4xLtiDNEej62+qs2nLYCaNxyP3Eq33GtBC+DJihZnKuqMpUqSpB76HlxeJWEFAGY2AIVuv4Vn3WNfty2kJX5XjW/wDzlTxG78ajHm8a+QHGKU1BCAkLp1p6+Jx8cSuI1kZxqpU+Xu0qmDFwWZN0Sglr";
			image3 += "fD5bjpT3rwx+27zjBPm5+OUQCXGaZ3Xcpv8ACNNNKSzTYJZdmG0aj4viNaTkH4+Z4Ve0qrodDa3dehWxuIjcggOl7XXdcLT3KwWDo4gSLkYAB3YhNurXb7KYcZNxssyenimMhgBJuJ8xOmhoyUf6+AfSgdidASWFqvxZeAh2yLG6yr2kMwBqyrST25RPtgB/2DNwoM5o3xhLKFF5Ne2lB5XFIIGEuvQ2NxTjk2w8uYzJGT2b2vuP0VDEh4vY3zEW4jpYG9Fkg8MkhKudirJvOLvX9LA2+qmvHNh5EbExmAoNx2/n";
			image3 += "16WbpU2i4vUJCw10Yi+nsqaDGjJ9IMqm1xttceyo8kaxwyu6CyXkcBtPkVU9dy7rm/frVAy8HaQYLkj4rHStLFicRLMXK7YrXO5GGvd1q7J4zgZlb0SsTgfEA20e0VZmplpqn9DKrlYG4XhLDptsRWnxFhfjZZ409MensC9RdWtelb4OMCQqqyg2DC+tu2mMORjJgyQ3KtbyADS+mlZk28Xfa1D/2Q==";

			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener ("complete", onImage3);
			loader.loadBytes (new Base64 (image3));
		}

		private function onImage3 (e:Event):void {
			texture3 = Bitmap (LoaderInfo(e.target).content).bitmapData;

			// ready
			stage.quality = "low";
	
			scene = new Scene3D; scene.root = new Object3D; 
			view = new View; view.camera = new Camera3D; scene.root.addChild (view.camera); 
			view.width = view.height = 465; view.camera.z = -500; addChild (view); 
			wasd = new CameraController (stage); wasd.camera = view.camera; 
			wasd.setDefaultBindings ();
			wasd.checkCollisions = true; 
			wasd.collisionRadius = 3; 
			wasd.controlsEnabled = true; 
			wasd.mouseSensitivity *= 0.4; 
			wasd.speed = 20; 

			var p:Plane = new Plane (SIZE * 10, SIZE * 10);
			for each (var f:Face in p.faces) {   
				var uv:Point;   
				uv = f.aUV; uv.x *= SIZE; uv.y *= SIZE; f.aUV = uv;   
				uv = f.bUV; uv.x *= SIZE; uv.y *= SIZE; f.bUV = uv;   
				uv = f.cUV; uv.x *= SIZE; uv.y *= SIZE; f.cUV = uv;   
			} 
			p.cloneMaterialToAllSurfaces (new TextureMaterial (new Texture (texture3),
				1, true, false, "normal", -1, 0, TextureMaterialPrecision.VERY_HIGH));
			p.x = (SIZE - 1) * 5; p.y = (SIZE - 1) * 5; p.z = -5;
			scene.root.addChild (p);

			p = p.clone () as Plane;
			p.x = (SIZE - 1) * 5; p.y = (SIZE - 1) * 5; p.z = N*10 -5;
			scene.root.addChild (p);

			// the reason for this fork is great idea by paq,
			// http://wonderfl.net/c/hNt6
			for (q = 0; q < N; q++) {
				initialize(); 
				boutaoshi(); 
				draw(); 
			}

		}
		
		private function boutaoshi():void
		{
			for (var y:int = 2; y < SIZE - 1; y += 2)
			{
				var dx:int = 2;
				var dy:int = y;
				
				switch (Math.floor(Math.random() * 4))
				{
					case 0:
						dx++;
						break;
					case 1:
						dx--;
						break;
					case 2:
						dy++;
						break;
					case 3:
						dy--;
						break;
				}
				
				if (!maze[dx][dy])
				{
					maze[dx][dy] = true;
				}
				else
				{
					y -= 2;
				}
			}
			
			for (var x:int = 4; x < SIZE - 1; x += 2)
			{
				for (y = 2; y < SIZE - 1; y += 2)
				{
					dx = x;
					dy = y;
					
					switch (Math.floor(Math.random() * 3))
					{
						case 0:
							dy++;
							break;
						case 1:
							dy--;
							break;
						case 2:
							dx++;
							break;
					}
					
					if (!maze[dx][dy])
					{
						maze[dx][dy] = true;
					}
					else
					{
						y -= 2;
					}
				}
			}
		}
		
		private var scene:Scene3D;
		private var view:View;
		private var wasd:CameraController;

		private function draw():void
		{
			var i0:int = 1, j0:int = 1;
			for (var i:int = 0; i < SIZE; i++)
			{
				for (var j:int = 0; j < SIZE; j++)
				{
					if (maze[i][j])
					{
						var box:Box = new Box (10, 10, 10);
						box.mobility = 1;
						box.x = i * 10; box.y = j * 10; box.z = q * 10; 
						for each (var s:Surface in box.surfaces) s.material =
							new TextureMaterial (new Texture (texture2));
						box.setMaterialToSurface (new TextureMaterial (new Texture (texture3)), "top");
						box.setMaterialToSurface (new TextureMaterial (new Texture (texture3)), "bottom");
						scene.root.addChild (box); 
					}
					else
					{
						i0 = i; j0 = j;
					}
				}
			}

			view.camera.x = i0 * 10; 
			view.camera.y = j0 * 10;
			view.camera.z = q * 10; 
			view.camera.rotationX = -Math.PI / 2; 
			view.camera.rotationZ = -3;

			addEventListener (Event.ENTER_FRAME, function (e:Event):void {
				wasd.processInput (); scene.calculate ();
			});
		}
		
		private function initialize():void
		{
			maze = new Array(SIZE);
			for (var i:int = 0; i < SIZE; i++)
			{
				maze[i] = new Array(SIZE);
			}
			
			for (i = 0; i < SIZE; i++)
			{
				for (var j:int = 0; j < SIZE; j++)
				{
					if (i == 0 || j == 0 || i == SIZE - 1 || j == SIZE - 1 || i % 2 == 0 && j % 2 == 0)
					{
						maze[i][j] = true;
					}
					else
					{
						maze[i][j] = false;
					}
				}
			}
		}
	}
}


// base64 code by 2ndyofyyx,
// http://wonderfl.net/c/pD5G
import flash.utils.ByteArray; 
class Base64 extends ByteArray { 
    private static const BASE64:Array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0]; 
    public function Base64(str:String) { 
        var n:int, j:int; 
        for(var i:int = 0; i < str.length && str.charAt(i) != "="; i++) { 
            j = (j << 6) | BASE64[str.charCodeAt(i)]; 
            n += 6; 
            while(n >= 8) { 
                writeByte((j >> (n -= 8)) & 0xFF); 
            } 
        } 
        position = 0; 
    } 
}
