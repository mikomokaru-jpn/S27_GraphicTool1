import Foundation

extension CGRect {
    //点が矩形領域内にあるか？
    func isInside(_ point: CGPoint) -> Bool {
        //x方向の定規
        var xFrom = self.origin.x
        var xTo = self.origin.x + self.width
        if self.width < 0{
            xTo = xFrom
            xFrom = self.origin.x + self.width
        }
        //y方向の定規
        var yFrom = self.origin.y
        var yTo = self.origin.y + self.height
        if self.height < 0{
            yTo = yFrom
            yFrom = self.origin.y + self.height
        }
        if (xFrom <= point.x && point.x <= xTo) &&
            (yFrom <= point.y && point.y <= yTo){
            return true
        }
        return false
    }
}
