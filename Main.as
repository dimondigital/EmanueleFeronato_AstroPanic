package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.net.SharedObject;
	import flash.text.TextField;
	
	public class Main extends Sprite {
		
		private const BULLET_SPEED:uint=5;
		private var spaceship:spaceship_mc;
		private var isFiring:Boolean=false;
		private var bullet:bullet_mc;
		private var enemy=enemy_mc;
		private var level:uint=1;
		private var enemyVector:Vector.<enemy_mc>=new Vector.<enemy_mc>();
		private var enemyToRemove:int=-1;
		private var score:uint=0;
		private var sharedHiScore:SharedObject;
		
		public function Main() {
			sharedHiScore = SharedObject.getLocal("hiscores");
			if (sharedHiScore.data.score==undefined) {
				sharedHiScore.data.score = 0;
				trace("No High Score found");
			}
			else {
				trace("Current High Score: "+sharedHiScore.data.score);
			}
			sharedHiScore.close();
			placeSpaceship();
			playLevel();
			addEventListener(Event.ENTER_FRAME,onEnterFrm);
			stage.addEventListener(MouseEvent.CLICK,onMouseCk);
			
		}
		private function playLevel():void {
		  for (var i:uint=1; i<level+3; i++) {
			placeEnemy(i);
		  }
		}
		
		private function placeEnemy (enemy_level:uint):void {
			enemy = new enemy_mc();
			enemy.level.text = enemy_level;
			enemy.killed=false;
			enemy.x=Math.random()*500+70;
			enemy.y=Math.random()*200+50;
			var glow:GlowFilter=new GlowFilter(0xFF00FF,1,6,6,2,2);
  			enemy.filters=new Array(glow);
			addChild(enemy);
			var dir:Number = Math.random()*Math.PI*2;
			enemy.xspeed=enemy_level*Math.cos(dir);
			enemy.yspeed=enemy_level*Math.sin(dir);
			enemyVector.push(enemy);
		}
		private function placeSpaceship()  {
			spaceship = new spaceship_mc();
			addChild(spaceship);
			spaceship.y = 479;
			var glow:GlowFilter = new GlowFilter(0x00FFFF, 1, 6, 6, 2, 2);
			spaceship.filters = new Array(glow);
		}
		
		private function onEnterFrm(e:Event):void {
			spaceship.x=mouseX;
			if (spaceship.x<30) {
				spaceship.x=30;
			}
			if (spaceship.x>610) {
				spaceship.x=610;
			}
			if (isFiring) {
				bullet.y-=BULLET_SPEED;
				if (bullet.y<0) {
					removeChild(bullet);
					bullet=null;
					isFiring=false;
				}
			}
			enemyVector.forEach(manageEnemy);
			if (enemyToRemove>=0) {
				enemyVector.splice(enemyToRemove, 1);
				enemyToRemove=-1;
				if (enemyVector.length==0) {
					level++;
					playLevel();
				}
			}
		}
		private function onMouseCk (e:MouseEvent):void {
			if (! isFiring) {
				placeBullet();
				isFiring=true;
			}
		}
		private function placeBullet():void {
			bullet = new bullet_mc();
			addChild(bullet);
			bullet.x=spaceship.x;
			bullet.y=455;
			var glow:GlowFilter=new GlowFilter(0xFF0000,1,6,6,2,2);
  			bullet.filters=new Array(glow);
		}
		
		private function manageEnemy(c:enemy_mc,index:int,v:Vector.<enemy_mc>):void {
			  var currentEnemy:enemy_mc = c;
			  if (! currentEnemy.killed) {
				  currentEnemy.x+=currentEnemy.xspeed;
				  currentEnemy.y+=currentEnemy.yspeed;
				  if (currentEnemy.x<25) {
					currentEnemy.x=25;
					currentEnemy.xspeed*=-1;
				  }
				  if (currentEnemy.x>615) {
					currentEnemy.x=615;
					currentEnemy.xspeed*=-1;
				  }
				  if (currentEnemy.y<25) {
					currentEnemy.y=25;
					currentEnemy.yspeed*=-1;
				  }
				  if (currentEnemy.y>455) {
					currentEnemy.y=455;
					currentEnemy.yspeed*=-1;
				  }
				  if (distance(spaceship, currentEnemy)<3025) {
					  die();
				  }
				  if (isFiring) {
					  if (distance(bullet, currentEnemy)<841) {
						  killEnemy(currentEnemy);
					  }
				  }
			  }else{
				  currentEnemy.width++;
				  currentEnemy.height++;
				  currentEnemy.alpha-=0.01;
				  if (currentEnemy.alpha<=0) {
					  removeChild(currentEnemy);
					  currentEnemy=null;
					  enemyToRemove=index;
				  }
			  }
		}	
		private function distance(from:Sprite, to:Sprite):Number {
			var distX:Number=from.x-to.x;
		  	var distY:Number=from.y-to.y;
		  	return distX*distX+distY*distY;
		}
		private function die():void {
		  	  var glow:GlowFilter=new GlowFilter(0x00FFFF,1,10,10,6,6);
			  spaceship.filters=new Array(glow);
			  removeEventListener(Event.ENTER_FRAME,onEnterFrm);
			  stage.removeEventListener(MouseEvent.CLICK,onMouseCk);
			  trace("Your score: "+score);
			  sharedHiScore = SharedObject.getLocal("hiscores");
			  trace("Current hiscore: "+sharedHiScore.data.score);
			  if (score>sharedHiScore.data.score) {
				trace("CONGRATULATIONS!! NEW HISCORE");
				sharedHiScore.data.score = score;
			  }
			  sharedHiScore.close();
	    }
		private function killEnemy(theEnemy:enemy_mc):void {
			  var glow:GlowFilter=new GlowFilter(0xFF00FF,1,10,10,6,6);
			  theEnemy.filters=new Array(glow);
			  theEnemy.killed=true;
			  removeChild(bullet);
			  bullet=null;
			  isFiring=false;
			  score+=int(theEnemy.level.text)*(4-Math.floor(theEnemy.y/100));
  			  trace(score);
			  t_scoreText.text = score.toString();
		}
	}
}