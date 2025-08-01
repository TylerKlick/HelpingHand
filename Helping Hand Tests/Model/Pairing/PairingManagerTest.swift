//import XCTest
//import SwiftData
//import CoreBluetooth
//@testable import Helping_Hand
//
//// MARK: - Mock Objects
//
//class MockPeripheral: CBPeripheral {
//    private let mockName: String?
//    private let mockIdentifier: UUID
//    
//    init(name: String?, identifier: UUID) {
//        self.mockName = name
//        self.mockIdentifier = identifier
//        super.init()
//    }
//    
//    override var name: String? {
//        return mockName
//    }
//    
//    override var identifier: UUID {
//        return mockIdentifier
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//class MockModelContext: ModelContext {
//    private var storage: [Device] = []
//    private var shouldThrowError = false
//    
//    override init(_ container: ModelContainer) throws {
//        try super.init(container)
//    }
//    
//    convenience init() throws {
//        let schema = Schema([Device.self])
//        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: schema, configurations: [configuration])
//        try self.init(container)
//    }
//    
//    func setShouldThrowError(_ shouldThrow: Bool) {
//        shouldThrowError = shouldThrow
//    }
//    
//    override func insert<T>(_ model: T) where T : PersistentModel {
//        if let device = model as? Device {
//            storage.append(device)
//        }
//        super.insert(model)
//    }
//    
//    override func delete<T>(_ model: T) where T : PersistentModel {
//        if let device = model as? Device {
//            storage.removeAll { $0.id == device.id }
//        }
//        super.delete(model)
//    }
//    
//    override func save() throws {
//        if shouldThrowError {
//            throw TestError.saveError
//        }
//        try super.save()
//    }
//    
//    override func fetch<T>(_ descriptor: FetchDescriptor<T>) throws -> [T] where T : PersistentModel {
//        if shouldThrowError {
//            throw TestError.fetchError
//        }
//        
//        if T.self == Device.self {
//            let sortedDevices = storage.sorted { device1, device2 in
//                device1.lastSeen > device2.lastSeen
//            }
//            return sortedDevices as! [T]
//        }
//        
//        return try super.fetch(descriptor)
//    }
//}
//
//enum TestError: Error {
//    case saveError
//    case fetchError
//}
//
//// MARK: - Device Tests
//
//@MainActor
//class DeviceTests: XCTestCase {
//    
//    func testDeviceInitWithNameAndIdentifier() {
//        // Given
//        let name = "Test Device"
//        let identifier = UUID()
//        
//        // When
//        let device = Device(name: name, identifier: identifier)
//        
//        // Then
//        XCTAssertEqual(device.name, name)
//        XCTAssertEqual(device.identifier, identifier)
//        XCTAssertNotNil(device.id)
//        XCTAssertNotEqual(device.id, identifier) // Should be different UUIDs
//        XCTAssertEqual(device.connectionState, .disconnected)
//        
//        // Dates should be recent (within last second)
//        let now = Date()
//        XCTAssertLessThan(abs(device.dateAdded.timeIntervalSince(now)), 1.0)
//        XCTAssertLessThan(abs(device.lastSeen.timeIntervalSince(now)), 1.0)
//    }
//    
//    func testDeviceInitWithNilName() {
//        // Given
//        let identifier = UUID()
//        
//        // When
//        let device = Device(name: nil, identifier: identifier)
//        
//        // Then
//        XCTAssertEqual(device.name, "Unknown Device")
//        XCTAssertEqual(device.identifier, identifier)
//    }
//    
//    func testDeviceInitWithPeripheral() {
//        // Given
//        let peripheralName = "Bluetooth Device"
//        let peripheralId = UUID()
//        let mockPeripheral = MockPeripheral(name: peripheralName, identifier: peripheralId)
//        
//        // When
//        let device = Device(mockPeripheral)
//        
//        // Then
//        XCTAssertEqual(device.name, peripheralName)
//        XCTAssertEqual(device.identifier, peripheralId)
//    }
//    
//    func testDeviceInitWithPeripheralNilName() {
//        // Given
//        let peripheralId = UUID()
//        let mockPeripheral = MockPeripheral(name: nil, identifier: peripheralId)
//        
//        // When
//        let device = Device(mockPeripheral)
//        
//        // Then
//        XCTAssertEqual(device.name, "Unknown Device")
//        XCTAssertEqual(device.identifier, peripheralId)
//    }
//    
//    func testUpdateLastSeen() {
//        // Given
//        let device = Device(name: "Test", identifier: UUID())
//        let originalLastSeen = device.lastSeen
//        
//        // Wait a small amount to ensure time difference
//        Thread.sleep(forTimeInterval: 0.01)
//        
//        // When
//        device.updateLastSeen()
//        
//        // Then
//        XCTAssertGreaterThan(device.lastSeen, originalLastSeen)
//    }
//}
//
//// MARK: - DevicePairingManager Tests
//
//@MainActor
//class DevicePairingManagerTests: XCTestCase {
//    
//    var mockContext: MockModelContext!
//    var pairingManager: DevicePairingManager!
//    
//    override func setUp() async throws {
//        try await super.setUp()
//        mockContext = try MockModelContext()
//        
//        // Use reflection to create instance since init is private
//        // In a real test scenario, you might want to make init internal for testing
//        // For now, we'll assume you've made it internal or created a test initializer
//        pairingManager = DevicePairingManager(context: mockContext)
//    }
//    
//    override func tearDown() async throws {
//        pairingManager = nil
//        mockContext = nil
//        try await super.tearDown()
//    }
//    
//    // MARK: - Initialization Tests
//    
//    func testInitialization() {
//        // Then
//        XCTAssertNotNil(pairingManager)
//        XCTAssertEqual(pairingManager.pairedDevices.count, 0)
//    }
//    
//    func testLoadPairedDevicesWithExistingDevices() throws {
//        // Given
//        let device1 = Device(name: "Device 1", identifier: UUID())
//        let device2 = Device(name: "Device 2", identifier: UUID())
//        mockContext.insert(device1)
//        mockContext.insert(device2)
//        try mockContext.save()
//        
//        // When
//        let newPairingManager = DevicePairingManager(context: mockContext)
//        
//        // Then
//        XCTAssertEqual(newPairingManager.pairedDevices.count, 2)
//    }
//    
//    func testLoadPairedDevicesWithError() throws {
//        // Given
//        mockContext.setShouldThrowError(true)
//        
//        // When
//        let newPairingManager = DevicePairingManager(context: mockContext)
//        
//        // Then
//        XCTAssertEqual(newPairingManager.pairedDevices.count, 0)
//    }
//    
//    // MARK: - Pairing Tests
//    
//    func testPairDevice() {
//        // Given
//        let peripheralId = UUID()
//        let mockPeripheral = MockPeripheral(name: "Test Device", identifier: peripheralId)
//        
//        // When
//        pairingManager.pairDevice(mockPeripheral)
//        
//        // Then
//        XCTAssertEqual(pairingManager.pairedDevices.count, 1)
//        XCTAssertEqual(pairingManager.pairedDevices.first?.name, "Test Device")
//        XCTAssertEqual(pairingManager.pairedDevices.first?.identifier, peripheralId)
//    }
//    
//    func testPairDeviceWithNilName() {
//        // Given
//        let peripheralId = UUID()
//        let mockPeripheral = MockPeripheral(name: nil, identifier: peripheralId)
//        
//        // When
//        pairingManager.pairDevice(mockPeripheral)
//        
//        // Then
//        XCTAssertEqual(pairingManager.pairedDevices.count, 1)
//        XCTAssertEqual(pairingManager.pairedDevices.first?.name, "Unknown Device")
//    }
//    
//    func testPairAlreadyPairedDevice() {
//        // Given
//        let peripheralId = UUID()
//        let mockPeripheral = MockPeripheral(name: "Test Device", identifier: peripheralId)
//        pairingManager.pairDevice(mockPeripheral)
//        
//        // When
//        pairingManager.pairDevice(mockPeripheral) // Try to pair again
//        
//        // Then
//        XCTAssertEqual(pairingManager.pairedDevices.count, 1) // Should still be 1
//    }
//    
//    func testPairDeviceWithSaveError() {
//        // Given
//        let mockPeripheral = MockPeripheral(name: "Test Device", identifier: UUID())
//        mockContext.setShouldThrowError(true)
//        
//        // When
//        pairingManager.pairDevice(mockPeripheral)
//        
//        // Then
//        // Device should not be added to pairedDevices if save fails
//        XCTAssertEqual(pairingManager.pairedDevices.count, 0)
//    }
//    
//    // MARK: - Unpairing Tests
//    
//    func testUnpairDeviceByInternalId() {
//        // Given
//        let mockPeripheral = MockPeripheral(name: "Test Device", identifier: UUID())
//        pairingManager.pairDevice(mockPeripheral)
//        let deviceId = pairingManager.pairedDevices.first!.id
//        
//        // When
//        pairingManager.unpairDevice(deviceId)
//        
//        // Then
//        XCTAssertEqual(pairingManager.pairedDevices.count, 0)
//    }
//    
//    func testUnpairDeviceByPeripheralIdentifier() {
//        // Given
//        let peripheralId = UUID()
//        let mockPeripheral = MockPeripheral(name: "Test Device", identifier: peripheralId)
//        pairingManager.pairDevice(mockPeripheral)
//        
//        // When
//        pairingManager.unpairDevice(withIdentifier: peripheralId)
//        
//        // Then
//        XCTAssertEqual(pairingManager.pairedDevices.count, 0)
//    }
//    
//    func testUnpairNonExistentDevice() {
//        // Given
//        let nonExistentId = UUID()
//        
//        // When
//        pairingManager.unpairDevice(nonExistentId)
//        
//        // Then
//        XCTAssertEqual(pairingManager.pairedDevices.count, 0) // Should remain unchanged
//    }
//    
//    func testUnpairDeviceWithSaveError() {
//        // Given
//        let mockPeripheral = MockPeripheral(name: "Test Device", identifier: UUID())
//        pairingManager.pairDevice(mockPeripheral)
//        let deviceId = pairingManager.pairedDevices.first!.id
//        mockContext.setShouldThrowError(true)
//        
//        // When
//        pairingManager.unpairDevice(deviceId)
//        
//        // Then
//        // Device should still be in pairedDevices if save fails
//        XCTAssertEqual(pairingManager.pairedDevices.count, 1)
//    }
//    
//    // MARK: - Query Tests
//    
//    func testIsPaired() {
//        // Given
//        let peripheralId = UUID()
//        let mockPeripheral = MockPeripheral(name: "Test Device", identifier: peripheralId)
//        pairingManager.pairDevice(mockPeripheral)
//        let unpairedPeripheral = MockPeripheral(name: "Unpaired", identifier: UUID())
//        
//        // When & Then
//        XCTAssertTrue(pairingManager.isPaired(mockPeripheral))
//        XCTAssertFalse(pairingManager.isPaired(unpairedPeripheral))
//    }
//    
//    func testGetPairedDevice() {
//        // Given
//        let peripheralId = UUID()
//        let mockPeripheral = MockPeripheral(name: "Test Device", identifier: peripheralId)
//        pairingManager.pairDevice(mockPeripheral)
//        let unpairedPeripheral = MockPeripheral(name: "Unpaired", identifier: UUID())
//        
//        // When
//        let pairedDevice = pairingManager.getPairedDevice(for: mockPeripheral)
//        let unpairedDevice = pairingManager.getPairedDevice(for: unpairedPeripheral)
//        
//        // Then
//        XCTAssertNotNil(pairedDevice)
//        XCTAssertEqual(pairedDevice?.identifier, peripheralId)
//        XCTAssertNil(unpairedDevice)
//    }
//    
//    func testGetPairedDevicesList() {
//        // Given
//        let peripheral1 = MockPeripheral(name: "Device 1", identifier: UUID())
//        let peripheral2 = MockPeripheral(name: "Device 2", identifier: UUID())
//        
//        pairingManager.pairDevice(peripheral1)
//        Thread.sleep(forTimeInterval: 0.01) // Ensure different timestamps
//        pairingManager.pairDevice(peripheral2)
//        
//        // When
//        let devicesList = pairingManager.getPairedDevicesList()
//        
//        // Then
//        XCTAssertEqual(devicesList.count, 2)
//        // Should be sorted by lastSeen (most recent first)
//        XCTAssertEqual(devicesList.first?.name, "Device 2")
//        XCTAssertEqual(devicesList.last?.name, "Device 1")
//    }
//    
//    // MARK: - Status Update Tests
//    
//    func testUpdateConnectionStatus() {
//        // Given
//        let peripheralId = UUID()
//        let mockPeripheral = MockPeripheral(name: "Test Device", identifier: peripheralId)
//        pairingManager.pairDevice(mockPeripheral)
//        let originalLastSeen = pairingManager.pairedDevices.first!.lastSeen
//        
//        Thread.sleep(forTimeInterval: 0.01)
//        
//        // When
//        pairingManager.updateConnectionStatus(mockPeripheral, isConnected: true)
//        
//        // Then
//        XCTAssertGreaterThan(pairingManager.pairedDevices.first!.lastSeen, originalLastSeen)
//    }
//    
//    func testUpdateConnectionStatusForUnpairedDevice() {
//        // Given
//        let unpairedPeripheral = MockPeripheral(name: "Unpaired", identifier: UUID())
//        
//        // When & Then (should not crash)
//        pairingManager.updateConnectionStatus(unpairedPeripheral, isConnected: true)
//        XCTAssertEqual(pairingManager.pairedDevices.count, 0)
//    }
//    
//    func testUpdateLastSeen() {
//        // Given
//        let peripheralId = UUID()
//        let mockPeripheral = MockPeripheral(name: "Test Device", identifier: peripheralId)
//        pairingManager.pairDevice(mockPeripheral)
//        let originalLastSeen = pairingManager.pairedDevices.first!.lastSeen
//        
//        Thread.sleep(forTimeInterval: 0.01)
//        
//        // When
//        pairingManager.updateLastSeen(mockPeripheral)
//        
//        // Then
//        XCTAssertGreaterThan(pairingManager.pairedDevices.first!.lastSeen, originalLastSeen)
//    }
//    
//    func testUpdateLastSeenForUnpairedDevice() {
//        // Given
//        let unpairedPeripheral = MockPeripheral(name: "Unpaired", identifier: UUID())
//        
//        // When & Then (should not crash)
//        pairingManager.updateLastSeen(unpairedPeripheral)
//        XCTAssertEqual(pairingManager.pairedDevices.count, 0)
//    }
//    
//    func testUpdateLastSeenWithSaveError() {
//        // Given
//        let mockPeripheral = MockPeripheral(name: "Test Device", identifier: UUID())
//        pairingManager.pairDevice(mockPeripheral)
//        mockContext.setShouldThrowError(true)
//        
//        // When & Then (should not crash)
//        pairingManager.updateLastSeen(mockPeripheral)
//    }
//}
//
//// MARK: - DeviceConnectionState Tests (if you have this enum)
//
//enum DeviceConnectionState {
//    case disconnected
//    case connecting
//    case connected
//}
//
//// MARK: - Test Extensions
//
//extension DevicePairingManager {
//    // Add this convenience initializer for testing
//    convenience init(context: ModelContext) {
//        self.init(context: context)
//    }
//}
