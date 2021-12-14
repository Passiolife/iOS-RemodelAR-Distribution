//
//  Republished.swift
//  Painty
//
//  Created by Davido Hyer on 12/14/21.
//

import Combine
import SwiftUI

@propertyWrapper
struct Republished<Object: ObservableObject> {
    static subscript<T: ObservableObject>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Object>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Object where T.ObjectWillChangePublisher: ObservableObjectPublisher {
        get {
            let stored = instance[keyPath: storageKeyPath].storage
            if instance[keyPath: storageKeyPath].subscription == nil {
                instance[keyPath: storageKeyPath].subscription = stored.objectWillChange.sink(receiveValue: { [weak instance] _ in
                    instance?.objectWillChange.send()
                })
            }
            return stored
        }
        set {
            if instance[keyPath: storageKeyPath].storage !== newValue {
                instance[keyPath: storageKeyPath].subscription = newValue.objectWillChange.sink(receiveValue: { [weak instance] _ in
                    instance?.objectWillChange.send()
                })
            }
            instance[keyPath: storageKeyPath].storage = newValue
        }
    }

    @available(*, unavailable)
    var wrappedValue: Object {
        get { fatalError() }
        set { fatalError() }
    }

    private var storage: Object
    private var subscription: AnyCancellable? = nil

    init(wrappedValue: Object) {
        storage = wrappedValue
    }
}
