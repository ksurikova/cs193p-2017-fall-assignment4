//
//  SetCardAreaView.swift
//  cs193p-2017-fall-assignment4
//
//  Created by Ksenia Surikova on 15.03.2022.
//

import UIKit

class SetCardAreaView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        var grid = Grid(layout: Grid.Layout.aspectRatio(SetCardViewConstants.cardAspectRatio), frame: bounds)
        grid.cellCount = cardViews.count
        for row in 0..<grid.dimensions.rowCount {
            for column in 0..<grid.dimensions.columnCount {
                guard cardViews.count > (row * grid.dimensions.columnCount + column) else {
                    continue
                }
                // rearrange animation
                if self.cardViews[row * grid.dimensions.columnCount + column].alpha == 1 {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.75,
                                                                   delay: 0.0,
                                                                   options: .curveEaseInOut,
                                                                   animations: {
                        rearrangeCell(grid: grid, rowIndex: row, columnIndex: column)
                    })
                } else {
                    rearrangeCell(grid: grid, rowIndex: row, columnIndex: column)
                }
            }
        }

        func rearrangeCell(grid: Grid, rowIndex: Int, columnIndex: Int) {
            self.cardViews[rowIndex * grid.dimensions.columnCount + columnIndex].frame =
            grid[rowIndex, columnIndex]!.insetBy(
                dx: SetCardViewConstants.spacingDx, dy: SetCardViewConstants.spacingDy)
        }
    }

    func addCardViews(_ newCardViews: [SetCardView]) {
        cardViews += newCardViews
        cardViews.forEach {
            addSubview($0)
        }
       layoutIfNeeded()
    }

    func removeCardViews(_ removedCardViews: [SetCardView]) {
        removedCardViews.forEach {
            _ = cardViews.removeIfContains($0)
        }
       layoutIfNeeded()
    }

    var cardViews = [SetCardView]() {
        willSet { removeSubviews() }
        didSet { addSubviews(); layoutIfNeeded() }
    }

    private func removeSubviews() {
        for card in cardViews {
            card.removeFromSuperview()
        }
    }

    private func addSubviews() {
        for card in cardViews {
            addSubview(card)
        }
    }
}
