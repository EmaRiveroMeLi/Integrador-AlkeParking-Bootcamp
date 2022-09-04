import UIKit

//MARK: - Protocol Parkable: ademas de los propiedades necesarias, tambien conforma el protocolo hashable, que permite comparar entre instancias de estructuras y sus propiedades (en este caso, la propiedad plate que sera fundamental).

protocol Parkable: Hashable {
    var plate: String { get }
    var type: VehicleType { get }
    var discountCard: String? { get }
    var checkInTime: Date { get }
    var parkedTime: Int { get }
}

extension Parkable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
}

//MARK: - Struct Parking: Aqui se va a desarrollar toda la logica del programa. Check-In, Check-Out, Comprobaciones, Listado de vehiculos, Cobros, etc.

struct Parking {
    var vehicles: Set<Vehicle> = []
    let maxVehicles: Int = 20
    var register: (vehicle: Int, fee: Int) = (vehicle: 0, fee: 0)
    
    mutating func checkInVehicle(_ vehicle: Vehicle, onFinish: (Bool) -> Void) {
        guard self.vehicles.count < self.maxVehicles && !self.vehicles.contains(vehicle) else {
            return onFinish(false)
        }
        self.vehicles.insert(vehicle)
        return onFinish(true)
    }
    
    mutating func checkOutVehicle(plate:String, onSuccess: (Int) -> Void, onError: () -> Void) {
        guard let vehicle = vehicles.first(where: {$0.plate == plate}) else {
            onError()
            return
        }
        
        let hasDiscound = vehicle.discountCard != nil
        let value = calculateFee(type: vehicle.type, parkedTime: vehicle.parkedTime, hasDiscountCard: hasDiscound)
        
        self.vehicles.remove(vehicle)
        self.register.vehicle += 1
        self.register.fee += value
        onSuccess(value)
    }
    
    mutating func calculateFee(type: VehicleType, parkedTime: Int, hasDiscountCard: Bool) -> Int {
        let timeInitial = 120
        let restTime = parkedTime - timeInitial
        let block = ceil(Double(restTime/15))
        let mount = Double(type.rate) + (block * 5)
        
        if parkedTime > timeInitial {
            if hasDiscountCard {
                return Int(mount * 0.85)
            } else {
                return Int(mount)
            }
        } else {
            if hasDiscountCard {
                return Int(Double(type.rate) * 0.85)
            } else {
                return type.rate
            }
        }
    }
    
//MARK: - Funciones de la Administracion.
    
    func reportParking() {
        print("\(register.vehicle) vehicles have checked out and have earnings of \(register.fee)"
        )
    }
    
    func listOfPlates() {
        vehicles.map { vehicles in
            print(vehicles.plate)
        }
    }
    
}

//MARK: - Struct Vehicle: Aqui definiremos nuestros vehiculos, conformando el protocolo Parkable (a su vez, el protocolo hashable)

struct Vehicle: Parkable {
    let plate: String
    let type: VehicleType
    let checkInTime: Date
    var discountCard: String?
    var parkedTime: Int {
        Calendar.current.dateComponents([.minute], from: checkInTime, to: Date()).minute ?? 0
    }
    
    static func ==(lhs: Vehicle, rhs: Vehicle) -> Bool {
        lhs.plate == rhs.plate
    }
}

//MARK: - Enum VehicleType: Aqui usamos un Enum para delimitar de forma segura los tipos de vehiculos, a su vez tambien contiene las tarifas fijas para abonar segun su tipo.

enum VehicleType {
    case car
    case miniBus
    case bus
    case moto
    
    var rate: Int {
        switch self {
        case .car: return 20
        case .moto: return 15
        case .miniBus: return 25
        case .bus: return 30
        }
    }
}

var alkeParking = Parking()

var arrayOfVehicles = [
    Vehicle(plate: "AA111AA", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_001"),
    Vehicle(plate: "B222BBB", type: VehicleType.moto, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "CC333CC", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "DD444DD", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_002"),
    Vehicle(plate: "AA111BB", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_003"),
    Vehicle(plate: "B222CCC", type: VehicleType.moto, checkInTime: Date(), discountCard: "DISCOUNT_CARD_004"),
    Vehicle(plate: "CC333DD", type: VehicleType.miniBus, checkInTime: Date(), discountCard:nil),
    Vehicle(plate: "DD444EE", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_005"),
    Vehicle(plate: "AA111CC", type: VehicleType.car, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "B222DDD", type: VehicleType.moto, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "DD444GG", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_006"),
    Vehicle(plate: "AA111DD", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_007"),
    Vehicle(plate: "B222EEE", type: VehicleType.moto, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "BC443YY", type: VehicleType.bus, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "DD338AA", type: VehicleType.car, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "GG569II", type: VehicleType.moto, checkInTime: Date(), discountCard: "DISCOUNT_CARD_007"),
    Vehicle(plate: "DD678JJ", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "HH444JJ", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_008"),
    Vehicle(plate: "HH777AA", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "DD333FF", type: VehicleType.car, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "DD333FF", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)
]
  
//MARK: - CheckIn de Vehiculos

print("********** CheckIn **********")

arrayOfVehicles.forEach { vehicle in
    alkeParking.checkInVehicle(vehicle) { verification in
        verification ? print("Welcome to AlkeParking!") : print("Sorry, the check-in failed")
    }
}

//MARK: - CheckOut de Vehiculos

print("********** CheckOut **********")

alkeParking.checkOutVehicle(plate: "HH777AA") { value in
    print("Your fee is \(value). Come back soon")
} onError: {
    print("Sorry, the check-out failed")
}

alkeParking.checkOutVehicle(plate: "GG569II") { value in
    print("Your fee is \(value). Come back soon")
} onError: {
    print("Sorry, the check-out failed")
}

alkeParking.checkOutVehicle(plate: "GG569II") { value in
    print("Your fee is \(value). Come back soon")
} onError: {
    print("Sorry, the check-out failed")
}

//MARK: - Listado de Patentes (Administracion)

print("********** CheckListPlates **********")

alkeParking.listOfPlates()

//MARK: - Reporte de Vehiculos retirados y ganancias.

print("********** CheckReportParking **********")

alkeParking.reportParking()








