import Quick
import Nimble
@testable import PerspectiveTransform
import simd
import GameKit

class CATransform3Dfrom2DSpec: QuickSpec {
    override func spec() {
        describe("weak perspective projection") {
            context("2D to 3D") {
                it("should add row and column and set 1 for z") {
                    let projection2D = Matrix3x3([
                        Vector3(11, 12, 13),
                        Vector3(21, 22, 23),
                        Vector3(31, 32, 1)
                        ])
                    let projection3D = CATransform3D(
                        m11: 11, m12: 12, m13: 0, m14: 13,
                        m21: 21, m22: 22, m23: 0, m24: 23,
                        m31: 0, m32: 0, m33: 1, m34: 0,
                        m41: 31, m42: 32, m43: 0, m44: 1)
                    expect(CATransform3D(projection2D.to3d())) == projection3D
                }

                context("random matrix") {
                    let source = GKRandomSource.sharedRandom()
                    var matrix: Matrix3x3!

                    beforeEach {
                        matrix = source.nextMatrix()
                    }

                    it("should have zeros in third column and row") {
                        let projection3D = matrix.to3d()
                        let third = 2
                        expect(projection3D[0, third]) == 0
                        expect(projection3D[1, third]) == 0
                        expect(projection3D[2, third]) == 1
                        expect(projection3D[3, third]) == 0

                        expect(projection3D[third, 0]) == 0
                        expect(projection3D[third, 1]) == 0
                        expect(projection3D[third, 2]) == 1
                        expect(projection3D[third, 3]) == 0
                    }

                    context("layer") {
                        it("should have components") {
                            let transform = CATransform3D(matrix.to3d())
                            var scale = transform.component(for: .scale)
                            let madeScale = CATransform3DMakeScale(CGFloat(scale.x), CGFloat(scale.y), CGFloat(scale.z))
                            print("madeScale:", madeScale)

                            var translate = transform.component(for: .translation)
                            let madeTranslation = CATransform3DMakeTranslation(CGFloat(translate.x), CGFloat(translate.y), CGFloat(translate.z))
                            print("madeTranslation:", madeTranslation)

                            let rotate = transform.component(for: .rotation)
                            print("scale, translate, rotate = ", scale, translate, rotate)
                            let b = atan(transform.m12/transform.m22)
                            let p = asin(transform.m32)
                            let h = atan(transform.m31/transform.m33)
                            let angle = b*b + p*p + h*h
                            let madeRotation = CATransform3DMakeRotation(angle, b, p, h)
                            print("madeRotation:", madeRotation)
                        }
                    }
                }
            }
        }
    }
}
