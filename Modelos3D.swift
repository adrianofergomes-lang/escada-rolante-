import SceneKit
import UIKit

let partNames = ["Motor elétrico", "Freio", "Encoder", "Redutor / engrenagem principal", "Reservatório de óleo",
                 "Corrente de acionamento", "Corrente de degraus", "Roda de retorno", "Tensor", "Degraus",
                 "Corrimão", "Saia", "Placa-pente", "Treliça", "Quadro de comando", "Totem de sinalização", "Display de falhas"]

typealias P3 = (Double, Double, Double)
let HP = Double.pi / 2

func vec(_ p: P3) -> SCNVector3 { SCNVector3(Float(p.0), Float(p.1), Float(p.2)) }
func col(_ h: Int) -> UIColor {
    UIColor(red: CGFloat((h >> 16) & 255) / 255, green: CGFloat((h >> 8) & 255) / 255, blue: CGFloat(h & 255) / 255, alpha: 1)
}
func cyl(_ r: Double, _ h: Double) -> SCNGeometry { SCNCylinder(radius: CGFloat(r), height: CGFloat(h)) }
func box(_ x: Double, _ y: Double, _ z: Double) -> SCNGeometry {
    SCNBox(width: CGFloat(x), height: CGFloat(y), length: CGFloat(z), chamferRadius: 0)
}
func tor(_ r: Double, _ p: Double) -> SCNGeometry { SCNTorus(ringRadius: CGFloat(r), pipeRadius: CGFloat(p)) }

func mk(_ g: SCNGeometry, _ c: Int, _ p: P3 = (0, 0, 0), _ r: P3 = (0, 0, 0), glow: Bool = false, alpha: Double = 1) -> SCNNode {
    let m = SCNMaterial()
    m.diffuse.contents = col(c).withAlphaComponent(CGFloat(alpha))
    m.lightingModel = .physicallyBased
    m.metalness.contents = 0.4
    m.roughness.contents = 0.5
    if glow { m.emission.contents = col(c) }
    g.materials = [m]
    let n = SCNNode(geometry: g)
    n.position = vec(p)
    n.eulerAngles = vec(r)
    return n
}

func gear(_ g: SCNNode, _ r: Double, _ n: Int, _ w: Double, _ c: Int, _ x: Double = 0, _ y: Double = 0, _ z: Double = 0) {
    g.addChildNode(mk(cyl(r, w), c, (x, y, z), (HP, 0, 0)))
    for i in 0..<n {
        let a = 2 * Double.pi * Double(i) / Double(n)
        g.addChildNode(mk(box(r * 0.28, r * 0.22, w), c, (x + cos(a) * r * 1.05, y + sin(a) * r * 1.05, z), (0, 0, a)))
    }
}
func chainRow(_ g: SCNNode, _ x1: Double, _ x2: Double, _ y: Double, _ n: Int) {
    for i in 0...n { g.addChildNode(mk(box(0.12, 0.07, 0.12), 0x8a6d3b, (x1 + (x2 - x1) * Double(i) / Double(n), y, 0))) }
}
func bar(_ g: SCNNode, _ a: (Double, Double), _ b: (Double, Double), _ r: Double, _ c: Int, _ z: Double = 0) {
    let dx = b.0 - a.0, dy = b.1 - a.1
    let len = (dx * dx + dy * dy).squareRoot()
    g.addChildNode(mk(cyl(r, len), c, ((a.0 + b.0) / 2, (a.1 + b.1) / 2, z), (0, 0, atan2(dy, dx) - HP)))
}

func makeModel(_ k: Int) -> SCNNode {
    let g = SCNNode()
    let BL = 0x2f7fb8
    switch k {
    case 0:
        g.addChildNode(mk(cyl(0.6, 2), BL, (0, 0, 0), (0, 0, HP)))
        for i in 0..<6 { g.addChildNode(mk(cyl(0.66, 0.08), 0x1d4f73, (-0.8 + Double(i) * 0.32, 0, 0), (0, 0, HP))) }
        g.addChildNode(mk(cyl(0.12, 0.8), 0xcccccc, (1.35, 0, 0), (0, 0, HP)))
        g.addChildNode(mk(cyl(0.3, 0.4), 0xb07cff, (-1.2, 0, 0), (0, 0, HP)))
        g.addChildNode(mk(box(1.4, 0.15, 1), 0x444444, (0, -0.65, 0)))
    case 1:
        g.addChildNode(mk(cyl(1, 0.12), 0x9aa5ae, (0, 0, 0), (HP, 0, 0)))
        g.addChildNode(mk(cyl(0.25, 0.3), 0x555555, (0, 0, 0), (HP, 0, 0)))
        g.addChildNode(mk(box(0.5, 0.6, 0.5), 0xe5322d, (0.85, 0, 0)))
    case 2:
        g.addChildNode(mk(cyl(0.7, 0.5), 0x555555, (0, 0, 0), (HP, 0, 0)))
        g.addChildNode(mk(tor(0.7, 0.06), 0xb07cff, (0, 0, 0), (HP, 0, 0)))
        g.addChildNode(mk(box(0.4, 0.3, 0.3), 0xb07cff, (0, 0.9, 0)))
        g.addChildNode(mk(cyl(0.1, 0.8), 0xcccccc, (0, 0, 0.6), (HP, 0, 0)))
    case 3:
        g.addChildNode(mk(box(2.2, 1.4, 1.2), BL))
        gear(g, 0.5, 14, 0.2, 0xdddddd, -0.5, 0, 0.7)
        gear(g, 0.35, 10, 0.2, 0xdddddd, 0.4, 0.2, 0.7)
        g.addChildNode(mk(cyl(0.1, 0.2), 0xd9a400, (0, 0.8, 0)))
    case 4:
        g.addChildNode(mk(box(1.6, 1.2, 1), 0xd9a400))
        g.addChildNode(mk(cyl(0.25, 0.1), 0xffffff, (0, 0, 0.55), (HP, 0, 0)))
        g.addChildNode(mk(cyl(0.2, 0.15), 0x333333, (0, 0.65, 0)))
    case 5:
        gear(g, 0.8, 16, 0.25, BL, -1.2)
        gear(g, 0.5, 10, 0.25, BL, 1.2)
        chainRow(g, -1.2, 1.2, 0.65, 14)
        chainRow(g, -1.2, 1.2, -0.65, 14)
    case 6:
        gear(g, 0.4, 12, 0.2, BL, -2)
        gear(g, 0.4, 12, 0.2, BL, 2)
        chainRow(g, -2, 2, 0.4, 22)
        chainRow(g, -2, 2, -0.4, 22)
    case 7:
        gear(g, 1, 20, 0.3, BL)
        for i in 0..<6 { g.addChildNode(mk(box(0.1, 1.8, 0.2), BL, (0, 0, 0), (0, 0, Double(i) * Double.pi / 6))) }
        g.addChildNode(mk(cyl(0.25, 0.4), 0x333333, (0, 0, 0), (HP, 0, 0)))
        g.addChildNode(mk(tor(0.75, 0.05), 0x1d4f73, (0, 0, 0), (HP, 0, 0)))
    case 8:
        for i in 0..<10 { g.addChildNode(mk(tor(0.35, 0.05), 0xcccccc, (-1.1 + Double(i) * 0.25, 0, 0), (0, 0, HP))) }
        g.addChildNode(mk(cyl(0.1, 0.7), 0x888888, (-1.5, 0, 0), (0, 0, HP)))
        g.addChildNode(mk(cyl(0.1, 0.7), 0x888888, (1.5, 0, 0), (0, 0, HP)))
        g.addChildNode(mk(box(0.08, 1, 1), 0x555555, (-1.2, 0, 0)))
        g.addChildNode(mk(box(0.08, 1, 1), 0x555555, (1.2, 0, 0)))
    case 9:
        for i in 0..<4 {
            let d = Double(i)
            g.addChildNode(mk(box(0.8, 0.1, 1.4), 0x4aa3df, (d * 0.6, d * 0.45, 0)))
            g.addChildNode(mk(box(0.1, 0.45, 1.4), BL, (d * 0.6 - 0.35, d * 0.45 - 0.22, 0)))
            g.addChildNode(mk(box(0.12, 0.03, 1.4), 0xf1c40f, (d * 0.6 + 0.32, d * 0.45 + 0.06, 0)))
        }
    case 10:
        let pts: [(Double, Double)] = [(-2, -0.6), (-1.4, -0.6), (-0.4, -0.1), (1, 0.7), (1.6, 0.9), (2, 0.8)]
        for i in 0..<(pts.count - 1) { bar(g, pts[i], pts[i + 1], 0.12, 0x222222) }
    case 11:
        g.addChildNode(mk(box(3, 0.3, 0.15), 0x8a8f94, (0, -0.2, 0)))
        g.addChildNode(mk(box(3, 0.8, 0.05), 0x9fd3ff, (0, 0.35, 0), alpha: 0.35))
    case 12:
        g.addChildNode(mk(box(2.4, 0.15, 0.9), 0xaaaaaa))
        for i in 0..<12 { g.addChildNode(mk(box(0.1, 0.08, 0.5), 0xcccccc, (-1.1 + Double(i) * 0.2, -0.01, 0.7))) }
    case 13:
        for zz in [0.0, 0.8] {
            for i in 0..<5 { g.addChildNode(mk(box(0.08, 1, 0.08), BL, (-1.6 + Double(i) * 0.8, 0, zz))) }
            for i in 0..<4 {
                let x0 = -1.6 + Double(i) * 0.8
                bar(g, i % 2 == 0 ? (x0, -0.5) : (x0, 0.5), i % 2 == 0 ? (x0 + 0.8, 0.5) : (x0 + 0.8, -0.5), 0.04, BL, zz)
            }
            g.addChildNode(mk(box(3.6, 0.1, 0.1), BL, (0, 0.5, zz)))
            g.addChildNode(mk(box(3.6, 0.1, 0.1), BL, (0, -0.5, zz)))
        }
    case 14:
        g.addChildNode(mk(box(1.4, 2, 0.6), 0xcfd8e0))
        g.addChildNode(mk(box(1.2, 1.8, 0.05), 0xe8eef3, (0, 0, 0.33)))
        g.addChildNode(mk(cyl(0.08, 0.05), 0x1ed760, (-0.3, 0.6, 0.37), (HP, 0, 0), glow: true))
        g.addChildNode(mk(cyl(0.08, 0.05), 0xff2a2a, (0.3, 0.6, 0.37), (HP, 0, 0), glow: true))
        g.addChildNode(mk(box(0.7, 0.3, 0.02), 0x0b1a0f, (0, 0.1, 0.36)))
        g.addChildNode(mk(box(0.5, 0.08, 0.05), 0x555555, (0, -0.5, 0.37)))
    case 15:
        g.addChildNode(mk(box(0.7, 2.2, 0.5), 0x222222))
        g.addChildNode(mk(cyl(0.22, 0.1), 0x1ed760, (0, 0.6, 0.27), (HP, 0, 0), glow: true))
        g.addChildNode(mk(cyl(0.22, 0.1), 0xff2a2a, (0, -0.1, 0.27), (HP, 0, 0), glow: true))
        g.addChildNode(mk(box(1, 0.15, 0.8), 0x555555, (0, -1.15, 0)))
    default:
        g.addChildNode(mk(box(1.8, 1, 0.2), 0x222222))
        let t = SCNText(string: "F18", extrusionDepth: 0.02)
        t.font = UIFont.monospacedSystemFont(ofSize: 0.5, weight: .bold)
        t.firstMaterial?.diffuse.contents = col(0x39ff6a)
        t.firstMaterial?.emission.contents = col(0x39ff6a)
        let tn = SCNNode(geometry: t)
        tn.position = SCNVector3(-0.45, -0.2, 0.11)
        g.addChildNode(tn)
    }
    return g
}

func makeScene(_ k: Int) -> SCNScene {
    let scene = SCNScene()
    scene.background.contents = UIColor.systemBackground
    let model = makeModel(k)
    let (mn, mx) = model.boundingBox
    let size = max(mx.x - mn.x, max(mx.y - mn.y, mx.z - mn.z))
    let holder = SCNNode()
    model.position = SCNVector3(-(mn.x + mx.x) / 2, -(mn.y + mx.y) / 2, -(mn.z + mx.z) / 2)
    holder.addChildNode(model)
    let s = Float(2.6) / max(size, 0.001)
    holder.scale = SCNVector3(s, s, s)
    holder.eulerAngles = SCNVector3(0.35, 0.6, 0)
    holder.runAction(.repeatForever(.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 14)))
    scene.rootNode.addChildNode(holder)
    let cam = SCNNode()
    cam.camera = SCNCamera()
    cam.position = SCNVector3(0, 0, 5.5)
    scene.rootNode.addChildNode(cam)
    return scene
}
