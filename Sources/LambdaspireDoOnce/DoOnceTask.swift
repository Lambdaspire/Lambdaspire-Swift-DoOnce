
import LambdaspireAbstractions

public protocol DoOnceTask {
    static func `do`(_ resolver: DependencyResolver) async
}
