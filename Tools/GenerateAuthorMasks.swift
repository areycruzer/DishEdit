import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

private let canvas = CGSize(width: 1_254, height: 1_254)

private struct Ellipse {
    let center: CGPoint
    let size: CGSize
    let degrees: CGFloat
}

private func makeMask(draw: (CGContext) -> Void) throws -> CGImage {
    guard let context = CGContext(
        data: nil,
        width: Int(canvas.width),
        height: Int(canvas.height),
        bitsPerComponent: 8,
        bytesPerRow: Int(canvas.width),
        space: CGColorSpaceCreateDeviceGray(),
        bitmapInfo: CGImageAlphaInfo.none.rawValue
    ) else {
        throw CocoaError(.fileWriteUnknown)
    }

    context.setFillColor(gray: 0, alpha: 1)
    context.fill(CGRect(origin: .zero, size: canvas))
    context.translateBy(x: 0, y: canvas.height)
    context.scaleBy(x: 1, y: -1)
    context.setFillColor(gray: 1, alpha: 1)
    draw(context)

    guard let image = context.makeImage() else {
        throw CocoaError(.fileWriteUnknown)
    }
    return image
}

private func draw(_ ellipses: [Ellipse], in context: CGContext) {
    for ellipse in ellipses {
        context.saveGState()
        context.translateBy(x: ellipse.center.x, y: ellipse.center.y)
        context.rotate(by: ellipse.degrees * .pi / 180)
        context.fillEllipse(in: CGRect(
            x: -ellipse.size.width / 2,
            y: -ellipse.size.height / 2,
            width: ellipse.size.width,
            height: ellipse.size.height
        ))
        context.restoreGState()
    }
}

private func write(_ image: CGImage, named name: String, to directory: URL) throws {
    let destinationURL = directory.appending(path: name)
    guard let destination = CGImageDestinationCreateWithURL(
        destinationURL as CFURL,
        UTType.png.identifier as CFString,
        1,
        nil
    ) else {
        throw CocoaError(.fileWriteUnknown)
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else {
        throw CocoaError(.fileWriteUnknown)
    }
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "DishEdit/Resources")

let tomatoMask = try makeMask { context in
    context.addPath(CGPath(
        roundedRect: CGRect(x: 250, y: 680, width: 755, height: 128),
        cornerWidth: 58,
        cornerHeight: 58,
        transform: nil
    ))
    context.fillPath()
}

let oliveMask = try makeMask { context in
    draw([
        Ellipse(center: CGPoint(x: 455, y: 286), size: CGSize(width: 70, height: 54), degrees: 0),
        Ellipse(center: CGPoint(x: 630, y: 276), size: CGSize(width: 70, height: 54), degrees: 0),
        Ellipse(center: CGPoint(x: 870, y: 327), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 320, y: 354), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 645, y: 396), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 798, y: 423), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 370, y: 436), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 500, y: 467), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 1_030, y: 457), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 250, y: 476), size: CGSize(width: 74, height: 60), degrees: 0),
        Ellipse(center: CGPoint(x: 395, y: 546), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 765, y: 522), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 975, y: 577), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 660, y: 587), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 1_045, y: 650), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 395, y: 650), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 235, y: 715), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 625, y: 706), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 895, y: 686), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 420, y: 812), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 610, y: 846), size: CGSize(width: 72, height: 58), degrees: 0),
        Ellipse(center: CGPoint(x: 930, y: 790), size: CGSize(width: 72, height: 58), degrees: 0)
    ], in: context)
}

let strawberryMask = try makeMask { context in
    draw([
        Ellipse(center: CGPoint(x: 715, y: 324), size: CGSize(width: 150, height: 92), degrees: 8),
        Ellipse(center: CGPoint(x: 545, y: 336), size: CGSize(width: 128, height: 86), degrees: 20),
        Ellipse(center: CGPoint(x: 395, y: 397), size: CGSize(width: 140, height: 105), degrees: 35),
        Ellipse(center: CGPoint(x: 545, y: 475), size: CGSize(width: 145, height: 94), degrees: 5),
        Ellipse(center: CGPoint(x: 370, y: 535), size: CGSize(width: 125, height: 105), degrees: 45),
        Ellipse(center: CGPoint(x: 490, y: 590), size: CGSize(width: 150, height: 90), degrees: -8),
        Ellipse(center: CGPoint(x: 270, y: 625), size: CGSize(width: 160, height: 102), degrees: 20),
        Ellipse(center: CGPoint(x: 445, y: 686), size: CGSize(width: 145, height: 90), degrees: 35),
        Ellipse(center: CGPoint(x: 565, y: 695), size: CGSize(width: 132, height: 105), degrees: 50),
        Ellipse(center: CGPoint(x: 350, y: 765), size: CGSize(width: 145, height: 108), degrees: 45),
        Ellipse(center: CGPoint(x: 555, y: 820), size: CGSize(width: 135, height: 105), degrees: 55)
    ], in: context)
}

let cheeseMask = try makeMask { context in
    context.addPath(CGPath(
        roundedRect: CGRect(x: 185, y: 685, width: 890, height: 205),
        cornerWidth: 54,
        cornerHeight: 54,
        transform: nil
    ))
    context.fillPath()
}

let iceCreamMask = try makeMask { context in
    draw([
        Ellipse(center: CGPoint(x: 800, y: 535), size: CGSize(width: 410, height: 405), degrees: 0),
        Ellipse(center: CGPoint(x: 800, y: 690), size: CGSize(width: 420, height: 145), degrees: 0)
    ], in: context)
}

let jalapenoMask = try makeMask { context in
    draw([
        Ellipse(center: CGPoint(x: 550, y: 295), size: CGSize(width: 92, height: 76), degrees: 0),
        Ellipse(center: CGPoint(x: 800, y: 315), size: CGSize(width: 92, height: 76), degrees: 0),
        Ellipse(center: CGPoint(x: 940, y: 400), size: CGSize(width: 92, height: 76), degrees: 0),
        Ellipse(center: CGPoint(x: 455, y: 415), size: CGSize(width: 92, height: 76), degrees: 0),
        Ellipse(center: CGPoint(x: 700, y: 470), size: CGSize(width: 92, height: 76), degrees: 0),
        Ellipse(center: CGPoint(x: 305, y: 540), size: CGSize(width: 92, height: 76), degrees: 0),
        Ellipse(center: CGPoint(x: 900, y: 520), size: CGSize(width: 92, height: 76), degrees: 0),
        Ellipse(center: CGPoint(x: 485, y: 610), size: CGSize(width: 92, height: 76), degrees: 0),
        Ellipse(center: CGPoint(x: 690, y: 670), size: CGSize(width: 92, height: 76), degrees: 0),
        Ellipse(center: CGPoint(x: 530, y: 800), size: CGSize(width: 92, height: 76), degrees: 0),
        Ellipse(center: CGPoint(x: 730, y: 875), size: CGSize(width: 92, height: 76), degrees: 0),
        Ellipse(center: CGPoint(x: 970, y: 740), size: CGSize(width: 92, height: 76), degrees: 0)
    ], in: context)
}

try write(tomatoMask, named: "burger_tomato_mask.png", to: outputDirectory)
try write(oliveMask, named: "pizza_olives_mask.png", to: outputDirectory)
try write(strawberryMask, named: "waffle_strawberries_mask.png", to: outputDirectory)
try write(cheeseMask, named: "burger_cheese_mask.png", to: outputDirectory)
try write(iceCreamMask, named: "waffle_icecream_mask.png", to: outputDirectory)
try write(jalapenoMask, named: "pizza_jalapeno_mask.png", to: outputDirectory)
