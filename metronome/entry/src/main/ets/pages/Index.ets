import systemDateTime from '@ohos.systemDateTime';
import { media } from '@kit.MediaKit';

@Entry
@Component
struct Index {
  timeList:Array<number>=[0,0,0,0,0,0,0,0,0];
  count:number=0;
  @State bpm:number=0;
  enableOfClick:boolean=false;
  @State isPlaying:boolean=false;
  @State beats:number=2;
  @State beatsNow:number=1;
  beatList:Array<number>=[1,2,3,4,5,6,7,8,9,10,11,12];
  @State colorList:Array<number>=[Color.White]

  intervalId:number=0;

  build() {
    Row() {
      Column() {
        Row(){
          Text('Bpm:'+this.bpm.toFixed(0))
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
          Button('click')
            .onClick(()=>{
              if (this.count !== 8) {
                this.count++;
                this.timeList[this.count]=systemDateTime.getTime(false);
              } else {
                this.count=0;
                this.timeList[this.count]=systemDateTime.getTime(false);
                this.enableOfClick=true;
              }
              if(this.enableOfClick){
                this.bpm=60*1000*8/(this.timeList[this.count]-this.timeList[this.count===8?0:this.count+1])
              }
              //需要处理不支持时间戳的设备getTime始终为零的情况
            })
            .enabled(systemDateTime.getTime(false)>0)
            .bindPopup(true, {
              message: '设备不支持时间戳',
              placementOnTop: true,
              showInSubWindow: false,
            })

        }
        .justifyContent(FlexAlign.SpaceAround)
        .width('100%')

        Row(){
          Text('30')
          Slider({
            value: this.bpm,
            min: 30,
            max: 300,
            style: SliderStyle.OutSet
          })
            .onChange((value: number)=>{
              this.bpm=value;
              if(this.isPlaying){
                clearInterval(this.intervalId);
                this.intervalId = setInterval(() => { this.playBeat(); }, 60000 / this.bpm);
              }
            })
            .width('80%')
          Text('300')
        }
        .justifyContent(FlexAlign.SpaceAround)
        .width('100%')

        Row(){
          Row(){
            Button('-')
              .onClick(()=>{this.beats>1?this.beats--:this.beats=this.beats})
            Text('Beats:'+this.beats)
            Button('+')
              .onClick(()=>{this.beats<12?this.beats++:this.beats=this.beats})
          }
          //后续加入超限弹窗
          Button(this.isPlaying?'Stop':'Start')
            .onClick(()=>{
              this.togglePlay();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)

        Blank()
        List(){
          ForEach(this.beatList.filter((value:number)=>value<=this.beats),(beat:number)=>{
            ListItem(){
              Row(){
                Row(){
                  Text(beat+'')
                    .fontSize(200/this.beats)
                }
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.colorList[beat])
                .height('100%')
                .width('100%')
              }
              .width(100.0/this.beats+'%')
              .border({
                width: 1,
                color: '#000000',
                style: BorderStyle.Solid
              })
            }
          })
        }
        .listDirection(Axis.Horizontal)
        .width('100%')
        .height('50%')

      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .height('100%')
  }

  private togglePlay() {
    if (this.isPlaying) {
      clearInterval(this.intervalId);
    } else {
      this.intervalId = setInterval(() => { this.playBeat(); }, 60000 / this.bpm);
    }
    this.isPlaying = !this.isPlaying;
  }
  private playBeat() {
    animateTo({
      duration: 0,
      iterations: 1,
      playMode: PlayMode.Normal,
      onFinish: () => {
        console.info('play end')
      }
    }, () => {
      this.colorList[this.beatsNow]=Color.Blue
    })
    animateTo({
      duration: 30000/this.bpm,
      curve: Curve.EaseOut,
      iterations: 1,
      playMode: PlayMode.Normal,
      onFinish: () => {
      }
    }, () => {
      this.colorList[this.beatsNow]=Color.White
    })
    this.beatsNow>=this.beats?this.beatsNow=1:this.beatsNow++;
    const audioPlayer = media.createAudioPlayer();
    audioPlayer.src = 'common/sound/beat.wav'; // 假设有一个节拍声音文件
    audioPlayer.play();
  }

}

