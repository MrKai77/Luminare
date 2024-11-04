extension NSTableView {
    override open func viewDidMoveToWindow() {
        super.viewWillDraw()
        selectionHighlightStyle = .none
    }
}