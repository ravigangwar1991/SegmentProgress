# SegmentProgress
Segment Progress like instagram story
//1
//Create Object for segment

    var SPB: SegmentedProgressBar!
    SPB = SegmentedProgressBar(numberOfSegments: item.count, duration: 5)
    SPB.frame = CGRect(x: 5, y: 50, width: UIScreen.width - 10, height: 2)
    self.SPB.startAnimation()
    self.SPB.pauseAnimation()
 
 //2
//Start download your image or start playing video adn resume animation after download image/video playing also pause animation
          //start animation
          
          SPB.resumeAnimation()
          
          //pause animation
          
          SPB.pauseAnimation()
   
  //3
 //implement delegate to get updated index to move forward or get staus of finsih story or sengment
 
    func segmentedProgressBarChangedIndex(index: Int) {}
    
    //2
    func segmentedProgressBarFinished() {}


