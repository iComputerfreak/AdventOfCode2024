// Copyright © 2024 Jonas Frey. All rights reserved.

import Foundation

fileprivate typealias Point = (x: Int, y: Int)

fileprivate enum Direction: CaseIterable {
    // Perpendicular
    case forward
    case backward
    case upward
    case downward
    // Diagonal
    case forwardUp
    case forwardDown
    case backwardUp
    case backwardDown
    
    var directionVector: Point {
        switch self {
        case .forward:
            return (1, 0)
        case .backward:
            return (-1, 0)
        case .upward:
            return (0, -1)
        case .downward:
            return (0, 1)
        case .forwardUp:
            return (1, -1)
        case .forwardDown:
            return (1, 1)
        case .backwardUp:
            return (-1, -1)
        case .backwardDown:
            return (-1, 1)
        }
    }
    
    func index(for point: Point, offset: Int) -> Point {
        return Point(point.x + self.directionVector.x * offset, point.y + self.directionVector.y * offset)
    }
}

fileprivate extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

fileprivate extension String {
    subscript(coordinate: Point) -> Element? {
        guard let line = components(separatedBy: .newlines)[safe: coordinate.y] else { return nil }
        guard coordinate.x >= 0, coordinate.x < line.count else { return nil }
        let stringIndex = index(startIndex, offsetBy: coordinate.x)
        return line[stringIndex]
    }
}

struct Day4Part1: Day {
    func run(input: String) throws -> String {
        let matches = searchForMatches(of: "XMAS", in: input)
        return "\(matches)"
    }
    
    private func searchForMatches(of word: String, in input: String) -> Int {
        // For any letter at position x, y, we can look at the following next letters to form the word XMAS
        // x+1, y and x-1, y (horizontal)
        // x, y+1 and x, y-1 (vertical)
        // x+1, y+1; x+1, y-1; x-1, y+1; x-1, y-1 (diagonal)
        
        var foundWords = 0
        // The origin of our coordinate system is at the top left (first letter is 0,0)
        for (y, line) in input.components(separatedBy: .newlines).enumerated() {
            for (x, firstLetter) in line.enumerated() {
                // We start by looking for the letter X, as any matching word has to start with that letter
                guard firstLetter == word.first else { continue }
                
                // Check all eight directions we can take from here and count the valid ones
                foundWords += Direction.allCases.map { direction in
                    checkDirection(direction, from: (x, y), word: word, input: input)
                }
                .map { $0 ? 1 : 0 }
                .reduce(0, +)
            }
        }
        
        return foundWords
    }
    
    private func checkDirection(_ direction: Direction, from point: Point, word: String, input: String) -> Bool {
        for (offset, letter) in word.dropFirst().enumerated() {
            let nextCoordinate = direction.index(for: point, offset: offset + 1)
            guard letter == input[nextCoordinate] else { return false }
        }
        
        return true
    }
    
    var testInput: String = """
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """
    
    var expectedTestResult: String = "18"
    
    var input: String = """
    MSMSMAXXAXXXXAXXAXMASMXSXMASMXMXMASMSSXASAMXSAMXXSAMXXMAMMSSMSSSMXSAMXXXXXSXSXSMSMMMMSXMASMMMSMSSSSMMMSAXSSSSSSXMASAMXMSSMMSMMMSAMSAMXAMAMXS
    SAAMMAMSSMMMSMMMSMXMXMAMAMAMAAMXMAMXAMXXMMSMSASXMSASAXXMXMAAXXAAAAMMXSMXSAAASAMAAMXSAMXXXAAAAAASAMMAAAMMMMAAAXMASAMXMAXAAAXAXAASMSMXMXSAMSAA
    XMXMMAXMAAXAAAMAAAAMXMASAMMXSAMXSSSMMSSXMXAASAMXAXAAXMXSAMSSMMAMMMXMMMSAAMMMMAMSMSAMASXMMSSMMSSMAMSSMSMSAMMMMMMMMMSSXMMSSMSASMXSXAAASAXMMMXS
    SSMSSSSSSMMSSMMSSSXSXSXMXSMAXAAAXAAXMAMAMXMXMMMASMMMXMAMAXAMAMSMMSAMSAMXSXSXMMMMAMXSSMXXAAAAAMAMXMAMAXASXXAMXMXAMXAAAXXAAMAMXMAMMMSMMASXMSMM
    SAAMAAAXAMXMAXAXXAAMAXMMSMMMSMSSMSMMMASXMASAMAXSXMXSAMMSXMASMMXAAMASMAMAMAMASAMXSMMMMXMASXXMMSSXMAMMSMMMAXSSMSSMSMMSMMMMXAXMASAXAXXXMXMAXXAA
    SMMMMMMMMSXSAMXSMMSMAMXXAAAAAXXAXMXASMSASASASMXXAMASMSAAXSAMXAMSMMXMMAMSSMXAMXMAXAXXMASMAMXSXMAAAAMMAMXMSMAAAMAMAAMMXAXXAXMSXSMSMXMMMASXMSSM
    MXAASMMXXAXXXAMXXAXAASXSSSMSSSSMMMSMSASXMXSMMMAXAMXSAMMSXMASMSMMSSXMSXSAAMSMSMMASMMASASXSXASASXSMMXSAMXAAMMMAMAXXSMASMMMSMASAXMAXAMASASAMAXM
    SSSXSAASMMSSSSXSMSMMASAAAXAMXMASAXASMXMASAMXAMAXAMAMXMAMASAMXMAAAMAAAXMMSMAAAAMASMMXMASAMMXXAMAMAAXAMXSSXMMSXMMSMXMAMSXAAMXMAMSMMASASXSAMMSM
    MAXASXMMAXSAXMASAAXSXXMMMMMMMSAMSSXSMMXAMASXMXSAAMASMMAMMAASAMMMMSSMASXAAXMMMMMXSXXAXAMXMAXMAMSMMMSAMAMMMSAMAMSAMXAAAMMSMSSMSMAXSAMASAXAMAAA
    MAMXMASMXMMMMMAMMMXAXSXSMXAAXMASAMAXASMMSMMASAXXXMXSMMSSMMXMASXXXAAMXMMSSSSMSXMASXSMSASXXAMSXMAAMASMMXSAMMAMAMSAMXAMXMAMAXAAAMXMAAMMMMMAMMSM
    MSSMSAMXAXSXXMASXMASMMMAMSSSMSXMASMSMMAXXASMMXSMMSAMAAAAAMMMMMMXMSSMXMAXAAXAXXMAMAXAAAMMMXXSASXSMMSASAMASMXMXMXAMAXMXMSSMSMMMMSASXMXAXMXSXMA
    XAAXMASMMSAMXMAMXXAAAAAAMMAXASMMMAXAMMSAMXMAXMAAAMASMMSSMMSASAAMAAMMSSMMMMMSMMXMMAMMMSMXXXAXAMAMXXMASMSMMXAMXXSAMXSSMMXAXXXSXAAMASAMXSAXSAMX
    MSSMSMSMMAASAMXMSMMSSMSSXMAMXSAASXXASAAMXSSMMAMSMXMMXMXMXAMASXSXMASAMXAAMMAMMMAMXAMXAAMMSSSMSMMSMMMAMMAXXXXMMXMXMAMAAXSAMMSXMSMSMMXMAMMMMAMS
    XAAAAAMAXMMXMMAAMAXAMXMAASXMAMMMMAMSMMXXMMAXMSXAXXSAMXAMMSMAMAXAMXMASMSMMMAXAMMSAAMMSSSMAAXSAXAAAAMMXSMSSMASAAMXMASXMMMAXXAAMAXSXSAMXSXXMXMX
    MXSSMSSMMXXMSXSASMMMSAMXMMAMASASXMMAASMSSSSMSXSMSMMAMSASAMMSMAMMXXXAMXMAXSMSASAAMMMXAAAMMSMSMMSSSMXSAASAASAMSASXSXSXMAAMAMXASMMXASXSMSASMSSS
    XMAMXAAXMXSAAAXAAMAXSASXSXXMASAMMASMSMMXAAXXSAXXAASAMSXMMSAAMSSMSSXMMAMMMSASAMXMMXSMMSMMMMASXAAMAXAMMSMSXMMXMMMMMXMASMSXSSMMAXSMMMXXAMAMMAMX
    SAMXMSSMSAMMMMMSMSSMSAMAMXXMXMAMSAMMAAXMMMMMMMMSSMMAXXXMXMMMMXAAAXAASMMSAMXMXMSMSXSAXMASXMAMMMMSAMXXMAMXXAMSXMAAXASAMAMMAMASAMSASXSMAMXMMAMM
    SXMAXXAMMASMXAXXMMAMMMMSMMSMMMXMMAMSSMMAASAAXMAAXXSXMXMSAMXXXSMMMSSMMSAMMXSMMXSAAASAMSAMAMAXXXAMXMSSSMSASAMMASMMSASXSAMSMSAMSASAMAMMXSAMMSSM
    XAMSMSSMSAMAMMSMXXAMASXMAXAMXSMASAMMAMXSXXXSXMSSSMMMSXASXMXMAXAAXAMMMMMXSASAMAMMMAMAXMASASMSMMXMAXSASAXASMAMMMAAMAMAMXXXXMXSXXMXMAMASMMSAMMM
    MSMMAMXASXMSXMAXMSXSASXSMMMSAASAMAMSAMMMSMXMAMAAAMAAXAXXMSSMASMMMASXXMAMMAMAMXSXSASXXMASAMXAMXSMSMMAMMMAMMSMXMMMMAMXMSMSMSMMXXSMSMMMXAAMASAS
    AAAXSAMXMAAXAXXMXAAMXSAAAAAMMXMXXAMSAMSAAMASMMMAMXMSSXXAMAXMAMXXAAAMAMMXSAXXMMXAXXMXXSAMXMSXSAXXXAMXMXAXMAMAAXXASMSMMSAAAAMAMXAAMAASXMMSXMAS
    SMMMXASXSXMSSMSMMMXMAXMSMMXSMMMMMSMMAMMSSSMMXASAXAMXAXMAMASMSSSXSXAMAMAXMAXSAMMMMAXMXMSSMASAMXSASXMXSSSMMMXSAMXXXMAMAMXMSMMSAAMSMSMSAMXXMMAM
    AXAASAMASMAXMAAAXAMSMXAXMXASAMXSAXMMAMXAXMAXXASAMSSMAMSSMMSAMAXMXMXXASMAAAAXMMAMMSMXMAMXAMMXMXAAMXAAMMAMMAAMAMSAMXSMXXMXMXAMXSXXXAMXAMXXMMAS
    MMMMMAMAMMSMMSMSMXMAAMSMXAXSASAMMSASXMMMMSMMMXMXMAAMXMAMAXMAMSMSAASXMMMXMMMXMMXSMASAMXMASXMASXMSMXMAMSAMMMMSASAMXSXSMMSAMXXSXMASMMSSSMMSSMAS
    MSMSSSMMSAMXXXAMXSMMSMAAXMASAMXSSMMMSAASAAAMXAAAMSMMSMSSSMSAMXMXAXSAMXSAXAAMSMAXXXMSMAMAMAMXAXXMXXAAAMASASAMXMXMMSAMXASAXSAMXMAMSXAMAAAAAMAX
    MAAXAMAAMASMSMAMAMXMXXSSXMAMAMAXMAMAXSAMMSSMSMSMXXAXXAAAAASXSAMSSMSXMASMSMSAAASAMXXXXAMASXSMMXSAMSSMMSASXMAMXMXMXMXMMASAMMSMAMAMMMASMMMXSMSM
    MMSMASXMSAMMAMSMSXAXSAXXAMXSSXMASAMSXMMSAMMAAAAMASMMMMMSMXMASAMAAAXAMAMXAMXMXSMSXMXSXMSASXXASAMAAAXAMMAMASMMAMAMAMASXMMMXMAMAMAXAAXMASMXMAXM
    SAXMXMAAMASMSMXAMAMSMMXSSMAMXAAAXAXXXAMSASMSMSMSASAAAAXAMXMMMXMAXASXMASMMSAMXMAXSMASAAMMSMSXMXSMMMSXMAMXXXSAASASASASAAMAASMSMSSSXSMSAMXSMAMX
    MASMSSSMMAMAXAMAMAXAAMAMAMASXMMXXSMSMSMSAMAAAXAMASXMXMSAMXMMMMMMSAMASMSAAMMSXMAMAMASMMMMXAMXMAMASXSAMXSSMMMSMXMSASASMMMXXSAMAAAMAMXMAMXAMMMA
    XMMAAAXMMXMXMMSSSMSXSMAXAMSAMXSMXXASAXAMMMXMAMSMXMMSAAMMMAXMASAAMMMASXMAMXMAMMXSMMXSMMSSSSSXMXMAMXSASAAXAAMASXXMMMASXMXXMMAMMMXMAXMMSMMMMMSX
    MXMXMMMXMXXXAMAMAXAXMXSMSSXMAMMMMMAMAMSMSSXMASAMXSASMSMAXXXSAMMXXAMASXMAMSASASAMXMAMXXAAXXAXSAMSSMSAMMSMSXSASXMASMSMMSSSXAMMSMSSMXSAAAAXAAXX
    MASAMAXMXASXXMAXMMSMSAMAXXAMMSAAAMAMAXXAASAXXMAMAMASXMMSXSASASAXSMMMMAMXXXAMAMXSAMMSMMMSMMMMMASAAAMXMXAXMAMXSMSMMMXASAAMSXMAXMASXAMASXMSMXSA
    SASASXMAMXMAASASMSMAMAMSMSMMASMSSSXMXSMMMSMMSSSMMMMMMMAMAMASAMAXAXAMSMMSSMSMXMASAXSAMAXAXAXXSXMXMMMAXMAMSAMAMXXAAASMMMSMAXMXSMMSMSSXXXAAXAMM
    MMSXMASXXSMSMMAMXAMMMAMAAAXMASAMAMMSMMXMAXAAAAXXASXSAMMMAMMMMMXAMXMMAAXASXMAMMXSXMSMSMSSSSSXMAMXMAXXSAMXSAMSSSMMMMMMXXMXMXMMXAXXMXAAMMXMMSSM
    SXXXMMMMAAAXAMXMSSMMXXSMSMSMASMMXMAAAXSXXSSSMAMSASASMSSMAMAAXMXMSASXSSMMSMMAAAXMMMMXMMXAAAAAMSXMMSSSMMSAMXMAAAASXMSSMMMAXSXSMMSSMMSMAAAXAMAM
    XXMMXAAMMMSMMMAMAAAAMMMMAMAMMSXSMMSSSMMMXAAXXMMSAMMMXAASASMSMXSMMAMAMXAXMASMSMXSAAMSSMMXMAMMMAAAAAMAAAMXMMMMMMMMAAAAAAMMMAAASMAMAAMXXSAMSSSM
    MSMASMSMSAAAXSXMXSMMXAASXMXSMXAAAXMMAMAAMMXMMMAMAMXSMMMSMSXXMASAMAMXMMSXSXMMAXASMXMAAXSSSSSSXSSMMMSAMXSMMAMXAAASMMMSSMXSAMXMSMAXMMXSMMXXXAAS
    AAAXSAAXMSSSMMASAMAXMSMMAXSXMMSMSAMXAMMXSMASAMAXASMSASASXSMSMASMMASAAXAASXSXXMMSAMMSMMSAAAAMMMMAMXAASXXAXXXSSSXXAMAAAXAAXSAMXMSMMAXXAXMMMSMM
    SASAMMXMMAXAAXAMAMSMMMAMAMMAMMAAXMSSSMXAAMASASMSMSASAMASASAXMAMXSAXMAMMAMASXMXAMMMAAAXMMMMMMAXMXMMMMMAMSXSAAXMASMXMASMMMSAMXXAMAMMMSAMXAAAAX
    MAMAMXAAMXXMSMMMMMMXASAMSASAMSMSMXAAAAMSSMMSAMXAXMMMAMMMAMXMMXMMMMSSMAXAMAMMAXMASMMMXXMAXSXSSSMXSAXSMXMAAMMMMMXAAAXXXMXXAAASMASAMAAXMASMXMSM
    MSMMSSMSXMMMAXSMAAMAMSMMXAXMMSAMXSMMMMMMAAAMASXMMSXSAMXMMMSMSXMXAMXAASMMMASASAMAMAMSSMXAMSAMAAAASMSASMMMSMXXMMMAMMMAXMXMSMMMMASMMMSSMXAMMSMM
    XXAXXMAXXAASMMMMMSSSMMMSMMMSMMAXAXMAMMXMSMMMAXAAAXMASAMXSAAAAMMASXSSMMAMSMSXMXSAXXMAMXAMMSAMSMMMSXSAMXAAMXMMAXSSMAXXMMMXMSAXSASMAMMAXMXXMAAA
    MSMMAMAMMSMSAXMAMXMAXXAAAAAMASMMSMMXXXMXXSSMASXMMMSAXXSMSXMMMSMAMAMAXXAMMASAMAMXSMMMSSXSASAMXXAASMMMMXSXSASAAMAXSXMMSMAAXMMMSAMXAXSAMXMXSMXM
    AAAAXMMXAAXXAMSSMASXMMSSSMSSXMMAXAMSXSAAXAXMMMMAMAMASXMASXXMAXMAMXMAMXAXSAXXMAMAAAASXMAMASAMXSMXSAAMMXMASASASAXXAMAMAMSSSMSAMAMMMXAMXAAMXSXX
    SSSMSASXSXSAMXAAMXMXMAMXAAMMMAMAMAMAASMSMMMSAASAMAMAMMMAMAMMMSMXMSMAMMAMMAMSSMSSSSMSMMSMMSAMMXMAXXMSMAMAMAMAXXMMSXSSMMAXAAMXSAMSSMAXSMSAASXS
    MXMAMAXXAXMAMMMSMMMMMMXSMMMMSSMXSSMMXMXMAXAMXXSXSASAMSMMSMXASXXAAXMASAMSMMMMAXAAMXAXXAAAASAMXAMXSXMAMASAMXMXMMSAMAXXXMAXMMMAMASAMMMMXAMMAMXX
    MAMMMAMXMSSSMSAAXAAAAMMSAMSXAXMAMAAXSSMSSMSSMXMAMMMXAAAAAXXMSAMMMMMAMMAAAASXSMMMMSXMMSSMMXAMMMSXAAMXSASMSMMSAXASMXMASXSSXAMXSMMMSAMMXMMMSSSM
    MSMXMMXAMXAXAMSMSSMSMXAXAMSMSSMSSSMMXXAAXXAAXMSASXSSSSSMXMMAMXMSMSMXXXSMMMSAXAXAAMAXMAXAMSSMAASXSXMAMXSMSAAASXMXMAMSMAAXXXSAAXSASAXXAAXAXAAX
    MXXXSASXSMSMMMXXAMXXAMSSSMXAXXAAMXMASMMMSMSSMAMAXAAAAAMXAMXSAMXAAAASMMMMSMXAXXMMAMSXMAXXMAAMMMSAAXSMSAMASMMMAMXASXSAMMMMMMMMMMMASAMSAMMSSSXM
    MSMAXMASMXMAMAXAMXAMAMXAAXMMMMMMSAMSSXXAMAAAASMSMMMMMMMMXXAMAMSMSMSMAAXSAAXSMSMSMSMMMSMMMSMXAXMXMMAAAMMMMAXXMASXMMSXSASAAAAAAAMXMXMXAXAAAAMA
    SAMSSXMMXXSAMASMXMMSSMSMSMXXAXMAMAXAXMMMSMSMSMAMAMAMXXAMXMXSAMAAXMAXMMMSMSAXAXMAXAAAAAAXXAAXSMMAXXMMMXSASAMXXMMASMXAMASMSSSMSMSAMXSSMMMSSMAM
    SASXMAAXMMSAMXAMAMXAXMMAAAASMSXMSSMAMSAMAMAXAMAMSSSSMXSAAXASXMMXMMMSXAAMXMMMSMSSSMSMSMSMMMSMMASMMSMSAMMAMSSXAXSAMMMMMAMMXXMAXMSASAMASAXAMXSM
    SXMASAMXAASAMXMSSSMSSMMSMSMAAAAMAXXMMAMMAMXXMMMMMXMAMAMXSMASXSAXSAASMMSSXAAAXAAAAAXAXAAAMAAMXMMAAMMMAMMXMAXMMMMAMXAAMASAMMMSMASXMASAXMMAMAAX
    XAMAMXXMMXSXMMMAAAAXAAAXAAMMMMMMASMMXXAMXSSMSASASASAMXSAXMMMAAMAMMXMASAMXXMSSMMMMMMAMSSMMMXSAASMMSXMXMSAMXSMMAMMMSSMMASMXMAMMXMASXMMSMSAMXSM
    MSSMMASXXAMAMXMMSSMXSMMSMMSSXSXMXMAXMSXSAAXASXSASASXSAMXSMAMXMMMXSMSSMMSSXAXAMASAAMAMMAMXAAMMXMMXMXMSMMASAAMSMSAAMASMMMXSXMXMASAMXXSAMXMASAA
    AMAASAXXMAXSMSXMAXXAMXXSAMXMAMMMMSSMXAAMMMMAXAMXMAMAMMSSMXAASXXMASMMXAXAMMMMMSASXSSMXXAMMMSSSSXMAXMXAAXAMMSMAASMMMAMXMSAMAMMSXMAMMMMAMSAMXXS
    SMSMMXSMSAMMXSAMXMASXSAMXMAMAMAAMAAAMMSMXXMSMMMMMSMXMAXAXMXMXASMAXAASAMXSAMAXMXSXXMMMMSMMXXAXAASMSSSSSMSSXMMMMMMAMMSMAMASXMAMASAMSMSAMXMAMXX
    AMMAXXAAXMASAXXMXXXXASXMASASMSSSMSSMMAMAMXAAAAXAAAAAMXSMMMSXAAMMXXXMSAMXSASXSXSXMSSSXAMAMMMMMSMMAAAXAAAXXXMAMXAXXSXAAMSAMXMAXAMXSAAMXSSSSSSM
    MMSAMXMASAAMXMSMMSAMMMASASXSAAAXAMXAMXSAMXMSMMXMSSSXMAAXAMMMMMAXSASXMASMMXMMSMMAXMAMMASAMAXXAMAMMMMMSMMMMXSAMSSMXMMXXXMASXSMMSSXMMSMMMAAAAMA
    XAAAXXXXSMXMAXSAAXXXXSMMXMXMMMMMSMSSMMSAMSXMAAXXAMAXMSMMXXAAASAMXMAAMASASXSASASMMMAMSMXASXSMSSSSSSMAXAMAMAMAMAAXSMMSSXSXMMMMAAAXMAXXAMAMMMMS
    MMSSMMMXMXAXMSMMMSXSXSXSMMSXSASMXAXMAASAMXASMMMMASMAXAASMXSXXXXXAXSXMASMAAMASAAXASAAAMMMMMXAAAAAXXMXSAMAMASMMSSMAAAAXAASAXAMMSSXMMSMSMAMSXAA
    MMMMMAMAMSMSMMAAASMSAMASAASASASAMSMSMMXMMMMMMXXSMMMMMMSMAAXXSXSSMMXMMXSXMXMAMMMSXSMSXSAMXSMSMSMMMXAAMMSAXAMAAAAASMMMSAMXXMAMXAMXSAAAMXSMMMMS
    XAAAXMMAXAMAAMSMXSAMXMASMMMAMAMMXXAMXSXXAXMAAMMXMAMXSXMMMSMAMAMXSAXMXAXAXMSSMSASMXAMASASXSAAAAXXMXMASAXMSSSMMMMMXXMXSXXXXMASMAMASXMXMAMAMMSX
    SSSSSSSMSASXSMXSAMAMMMXSMXMXMXMSAMMMAMMSSSSMMXSAMSMAXSMAXXMAMXMAMSSMSMSSMMAMXMASXMAMAMAAAMSMSMSMXSXMXMXAAMXXAAXMMXMAXSAMXMASXMMASMSSMASAMXAX
    AAXAAAAXSXMAMXSMMSSMMAAXMAMXXAMMASXMAMXAXMASMAAXAMMMSXSMSMMMXAMMMAXMAMAAAMAMAMAMASXMXMXMSMMMMAMMAMXMASMMSSSSSMSAMXMAMAXSAMASAMMXSXAAMXSMMMSS
    MSMXMMMMMMSMXSAMXAAASMSSSSSSMSAXAMXMSMMMSXAXMMMMAMAXMMMXSAMSSMSSMSSSSMSSSMMSSMSSMMASAMXXMASAMAMMXSXMAXAAAAAAAXMAMXMSSSMSXSXSXMXMMMSSMMMMXSAS
    MMMMMAMAAAAXMXMSMASMMXAMXXAMXXAMSSSXXASXMMMMMAXMAXMMMXSAMXMAAAAAXXMAXAAAXXXAMXAAASAMASMMSAMAMMSMAMAMSSSMMSMSMMSMMMAMAAAXAXMSXMASAAMAXMMAMAMM
    MAAAMASMMXSSMAXXMAMASMSMSMSMAMAMAAXAXXMASXXASXSMSAAXSMMSXMMSSMSSMSMAMMMMMXMAMMSSMMASAMMAMASXMXXMAXAMAAAXXMMAMMAAAXAMSMMMMSASASASMSSMMMSASMXA
    XSSMMASXSAMXMAXXXAXXMAAAXAMMXSAAMXMXMMSAMXMXSAAAMMMXSASAMSAAAXAXMXMAMMXAXSMSMXMXXXMMXSXASXMMXXSSMMSSSMSMXASASMSSMSXXAMXAXAXSAMASAAMAAXXAMXSX
    AMAMSASAMXSXSSSSMMSAMXMAMMMAMXXSSSMAXMASASAMXMMMMAMAMXMAAMMMSXXAMAXAMMMSAAAMSAMMMSSMMXMMSAMXAAXXXXXAXAAXMMMXSAXXMAMSAMSMSMAMXMAMMMSMMMMAMASM
    XMAMSAMASASMAAAXXAAAASXXMAMASXAXAAXAMMXMMMAXXXAXMAMMXSMXMAAAXMSXSASXXMAXMMSMSXSAXAAASMMXSMMSSMMSMSMAMSMMAASXMXMAXXAMAMMXMXAAXMASAAXMASMSMAMA
    SMSMMASXMAXMMMMMMMSSMMXSXMMAMMMMSMMSXSAXAMXMSSMSSSMSAAXSXXMASAAXMAMAAMSMXXMAMASMXMSMMXMAMMAMAXXAAAMAMAMXSMSMSXSXMMMMAMMASMMSXSASMXSXXAAMMMSS
    MAXXSAMMMSMSXAAAAAAXAMAAMSSXXASAMXXMASASMMMAXAAXAAAMMSMXASMXMMMSMSMMMMAAXMMAMMMXAXXXMMMSMMASMMXMSMSMSMSAMAXAXMSAMASMMMSMSAMXAMXSXASMSMSMAXAM
    MAMAMASAAAMXXSMSSSMSAMMSAAAMSMMMMMMMAMXSAASMSMMMSMMMMMXSMXMAMAXAAMSMSXMMSASXSMAMXXSAXAMXASASASAMXMAMAXXAMAMSMASXMASASAAXSMMMXMAMMMXAAAMMMMMM
    MMSXMSSMSSXSAMMAMAXSXXXMMMMMXAAAXAAMMXAXXMMAAXMAXXXSXMAMMAMAMMXMSMSXMASASMMXAMXMMASXMSASXMASAMXSASMXXSMMMAMMAMSMMASAMMXXMXSMXSMXSSSSMSMAMSSS
    MAMXXXXAMAASAMMASXMMXSXAXSSMMSSSSSSMSMMSXXMAMXMAMSAMAMAXXASMSMSMMASXXAMAMXSSMMASMAMMAMXMMMXMAMAXXMXSMMASAMXXMXMASAMMSSMSMAXMASXMXAAAXMMMMAAM
    SSSMSMMMMMXMAXSASMAMAMMSXMAAAAAXMAMAMAASMSMMMXMASMASXMAMSASAAAAAMAMMSSMSMMXAXSAAMXXSSXMMASMSSMSMMSXAASAMASMMSMSAMXSAAAMMMSSMMSASMSMMXXAXMMSM
    XAAAMAAXAXXMAMSAMXAMXSAMASXMMMMMMAMMMMMMAXAAXMMSXMAMXXAMXAMMMSMSMSMXAMAMMMMMMSMMXSAAXAASXMXAAMAASASMXMASXMAAAXMXSAMMSSMAAAXAMSAMAMXXXSSSXSXM
    MSMMXMMXAXXMAMXAASXSSMASAMXXSSMXMSSXMXSMSSSMSMXMASMMAMSASXSSXMMAAXAMMMSMMSASAMAAAMMMMXMMASMMSMSSMAXXASMMAMMSMAXSMMSAAAMMSSXMMMMMMMMXXAAXMASX
    AXAXXMSXMSMAMMXXMXXMAMMMMMSMSASXAXAMXAXAAAMAXMSMAXAMAAAASAXMAASMMMAMXAAAASAMMSMMMMAAXMASAMXAXAMAMAMSXSMXMMAMXSMXMXSMSXMAMAMSAMXSXAXAMXXAXMMS
    MSMMSMAASAMAMXSSMSMSMSSXXAAXMAMMSMAMMASMMMMSMXXMAMAMMSMSMXMSMMAAMMAMXSSSMMAMAXMASXSMSAMMASMAXAMAMXXMAXMASMMSAXAMSAMXMAMMSAAXAMAMASXSAMMXMXSA
    MAXAMMAMSASXSASAAMAXXXAAMSSXMAMAMAAXXXSAAMAMMMSXXAAXXMXXAXXASMMSXSASAMXAASAMSSSMSAXASXXSXMMSSSMSMSAMMMXXMAXMMMMAMAXAMXMXSMSMXMASAMAXAXSAAMSM
    SSMMSSSMXAMXMMMMMMXMMMMMMAAMSAMXXMSAMXXXMMASAMAMXMXSXMASXMSMAXAAXMAMMSAMXMAMAAXMMAMAMMMMAXAMXXAAAMSASMSMSMMAAAMSMSMXSASXXXAAASXMASASMMSXSASX
    AAAAAAMMMSMXMAXSAXSAMAMAMSSMSAXASXAASASXSSXSASMMMSMMMMASAMXXAMMSSMMMSXAXSXMMMMMMMMMAMAASMMSSMXMMSMXXXAAMASASMXXAAAMXMASAMSXSMSASAMXAMXXAMAMA
    MMMMMSMAAAASAMXSASXMSASXMMAMXMMSAMXXMXSAAXASMMAAAAAMSMXSASAXXSAAAAAXMAAXMASMMXSAAASMSMMXAXAAASMAXXXXMSMSMAXMSSXMSMSXSAXAMMMMXSAMXSAXSAMXMAMA
    SXMXAMMMSMSAAMAMXMAXSAXXXSXMAMXMAXMMMXMMMMMMMSXMXXXMAMXMAMXSMMMSSMMSSXMSMAMAAAXMMXXAMXSSXMSSMXMAMMSMMXXAXMXMASMXAMXMMMSAMXAXMMXMXMMXSAXXXAMA
    AMXMAMAMXMXMSMAMAMXXXMXSXMASASXSXMAAMAXAMAAAAXASASXSXSAMAMXXAXXAAAAAXAAXXASMMMSSSSMMMAXMAMXAAXMMMAAAMAMXMXXMASMSAXXXAAMASMSSMSAMXMSAXSAMSSSM
    MAMASMMSMMSAXXMSMSAMXMASASAMXSAMXAMSSMSSMSMSSMMMASAAXSXMAXSMMMMSSMMSXMMASASXMAMXAAAXSMMMMMXMMSMAMSMSMMSAAMXMXSASAMSSMXSAMXXSMAAXXSMMSAXMAAAM
    SSMAXMASAAMMMMXAMXAMAMMMAMXSASASMSMAMAAXAMXAXAXMAMMMMMASMXSAAAXAXMAXXSAMXAXMMAXMMMMMAXAAAMXSAMXAMXAMAXSXSMASAMMMAMXAAMMMXAMXSSSMXAMXAMMMMSMX
    AAMMMMASMMMSAMSASMSMSSSMSMMMASMMAAMXMMASMMMSSSMMMSXMAMMMMAMSMMSSSMAMASMSMSXXSSXSASMSXXSMMXAMASXSSXASAMXAAMXMAMAMMMSMMMXSMSMAMMAXMMSXMXSAAXXM
    SXMXAMXMXSXMAMSAMAXXMAXXXAXMMMASXMMMSXAAXAXMAMXAAXMSMSMSMSMXMMXMSMASASAXAXMMMMASASASAXMASMASMMMMXMXMAMXXMXMASAXSSXMMSSMSAAMASMMMMXAAMASMSMSA
    MASXMSSXAXXMXMMAMAMAMXMASMMMMSAMMSXAXMSXSASMSMSMMSAASAXAAAXMAMSAXSMAAMAMAMAMAMMMXMAMSAMAMSAMXAAXXXXMASXSMXMAMMAMXAAAAMAMSMSMSAASMAXSMASXMAMS
    MXMAMAMMMMMMSSSSMASXMMSMSAMAAMASAMMXSXMAMAXAAAXAAMMMSXMMMMSAAAMXMASMSMSSSSSMMSSMXMXMMXMAMXMASMSSSMXMASMAMAMASAMXSXMMSMSMMXSASXMSSSXXMASMMAMX
    MSMSMASMXAASAAAXSASAMASXSAMMXSAMASMXSAMAMMMMMSMAMXAMXXMXMAMMMXSAAASXXAXSAAMAMAAMMSAXSMMSXMAXAXXAMXAMAXMASXSASXSMMXXXXAMASAMMMXMXAMASMXSXSSMM
    AAAMSXMXSMMXMMMMMSSXMASXMAMXMMMMMMMAMASXMMMSMMMAXSMSAMXAMASXSASXMAXXMMMXMASAMSXMAMAXXAAXXSSMSSMSMXXMAXXAMXMASMMAXXMMMAMAMMMMSAMMXMSMAXMASASX
    SMMMAMXMMSSSMMSXMAMAMSSXMSMMMAMAMAMXSXMMASXAAAXXMAMMASMMSXSAMXSAMXSSMMAXXMXAXAAMMSSMSMMSXSAAMAAAAXMSMSMXSAMMSASXMMSASAMSSMSASMSAMSASXMXXSAMX
    MMMSXAMMAAMAAMMMMASXMMMXAAMAMSMMMASAXMASAMSSXMXAXMXSAMXXSAMXMXXXMAMAAXASMSSSMMMSMAMMXAAMXSMMMMSMSMAAAXASXXSASMMXSAXMXAMXAAMASXMAXSAMMMXXMXMM
    SAMXASAMMSSSMMAASMSMAAAXSAMMMXAMSMMMSSMMAMAXXMASMMAMASMMMMSAMXSMSSSSMMASAAAAXAAMMAMMSSMSMXAAXMAXAAMASMMMMMMASMSAMMSSSSMSMMMASAMSMMSMAAMSMAMA
    SAMSMMXSAXMMXMSXSAMXSMAMXMXMAMMMAMAAMAXSXMASMXMAAMASAMMAASXMMXMAAAAAXXAMMMMMSMSSMMMMMXAAMXSMSSSXSSXXXXXAMSMSMMMXSASXAAAXAXMASAMXMAMSSMAASAMS
    MMMSAAXMXSAMSMMXMMMAMMXSASXMASXSAXMSSXMSAMXMMAXSXMXXMAXSXSAXSAMXMSSMMMSSMXAXSAMAASXSSMSMSAXAXAAXXAXSAMXSMAXMMSAMMXSMSMMMMSMAXMMAMAXXXMSXSMSX
    MAMMMMSAAMAMSASXMXMSMSASAMASASMXMASXMASMMMAAMAMXMSMXXSXMASAMSXSAAAAAXXMAMMAMMAMSMMAXAAAAMMSAMMMMMAMMAMAXXMXSAMAMSAMXMXSXAAMMSMSSSMSAXMAMXMAM
    SMSMSASMSMMAMAMASAMMAMASMXXMASAMXMXAMXSAAMSSSMSAXAAXAXAMXMSXXASMSSSMSASAMSSMSXMXMMMMXMMAMAMAMXMAMMMSAMXSAXXMASAMMAMMSASMMXSXAMAMAAMMMMMMSMAX
    AXAAMASAAMXAMAMMMASMAMXMAMSMMMMSSMSSMXMMMXMAAAXMMMSMMSAMXAXMMAXXAXMASAMAXAAMXXMMSAXMSMXMMMXSXMXXXMAXAMAMMMMXMMXXSSMAMASXAAXMMMASMMMMMAAASXMX
    MMMSMAMXMASXSMSASXMXSMAMSXMAAMXAAXAASXXXMSMMMMMSAMXXAAAXMSAXMXMXSMMMMXMMMSSMSMSASXXMASAMASMMASMSSMMXSMASXXSAXASXAAMAMSMMMXMAASXSAXXAAMMMSASM
    AAAAMXXAXMXAAASASXMAXMXSAAXSMMMSSMSAXSAMXAAMXMAMAXAMMMMXAMMXMASAMXASAMXMAXMXAAMXSMMMAMMMAXASAMAAAASAMXMMAAXAMXMMMMMAMAAAAXMSMSASXMSXSSSXSAMS
    SSSXSXSMSMMMMMMXMMMMMMXMMSMAAXAMXXMASASMSXSMAMSSSMMSMSMMAXAAXAMMSXXXAMMXSXMSMSMXXAAMXSXMASMMMMXMSAMXSXSMMMMSMMMAXXSSSMSSSXAAAMAMAMXMMXMAMAMA
    XAAMXMAMAMAXXXMAMAMMAMXAAXXSMMSSMXMXMAXXAAXMASMAMAXAAAXMASMMSMMMSASMXMASMAMXXAMSMMMSAAMSXMMAXAMXAMXAMXXXXAAAAASMSXSXAAAAAMMMSMSXXMAMXAMMMSMM
    MXMMSAXSASAMXSSMSMXSASAMXXXMAXMMMASAMAMMMSMAXXMASXSMMXXXMAXXAMXAXXMAXMSASAMXSXXAAAAAMMMSASMSMMSAMXSAMXSMSMSSSMSASMSSMMMMMXXSAMXMMXSSSXSAAAAX
    XMXMAXMMASMSAAAAAXXMASXMASMSSMSAMMSXSASMMMMMMXMXSMXAMSMMXAXSXSMSSSSSMMXMSMSXSMSSSMSSXSASAMAMSMXAXMAAXAAXXXMAMMMXMAXXXAXMAMSASMMSAAMAMXSMMXMM
    XMAXMXSMMMAMMSMSMXXMXSAMXAMAAASASAMXSMMMAAAMMXMAMAMAMAAXMXASAXAMAXAAMXSAMASASAAMAMXXAAXMAMAMMSSSMASMMSMMSMMMXMASMSMXMASMAMMAMXAMMSMAMASXSSSS
    XXMMSAAASMXMAXMAXMXSMSMMMXMMMXMXAMAAXAASMSMMXAMASASXSMXSAMAMMMSMMMSMMXMAXXMAMXXXSMSMMMMSXMXSMAMXMMAXAAAMMAMMAMSMMMMMMAMMMMMAMMSMMXXAMXMAXAAA
    SXSAMXSAMXAMMXSASMMMAXXXSMSXXXAMMAMMSMMSAXMASXSMXAXAMAAXXMXAXAXAMXMASMXSMAMXMMXSMMSAAXAXASXMMASAMASMSMSMSAMMASAAASAAMSSXMASASAXAAXSXSAMSMMMM
    SMMASAMAMXXXAXMAMAAMSMMMMASAMSAMXXSAMMAMXMMASAAMMSMMMMMSXMSMMMMMMAXSXMAMMSMSMSXAAASXMMXSXMAASMSXSAMMAMMMSMSSXSXSMSXMXAAASASASMSMMMMXMASAAXAX
    MASAMXSXXXMMSSXASMMMAXAMMAMAXXMXXXMAXXMSMSMASMSMXMASXMXSAMAMASAMXSMMAMASAMASAMSSMMXAXSASASXMSAMXMASMAMXASAMXAMAMMSXSMMSMMASXMXSAMMSASMMMSMSA
    MMMASXSASMAMAMXMAMMSMSXSMSSXMASXMSMSMMXAAXMASAXAAASMASAMASXMASASMMASAMASAMAMAMAXXXSMMMAXAMMXMAMXMMMMMSMMMMMMMMAMAXAMMAMMMAXXSXXAMAAMASAXXAAX
    SMSMMMMAMMAMXMAXAXXAXAXSAMXASAMAAAAAMAXMSMSXMMMXXMAXAMASXMXXASXMASAMASASAMXSAMSSMXSXAMAMSMMASAMSMASXMAXXAMASXMSMSMAMMAMXMMSAMMSSMMSXMXXMASAM
    AXAAAXMAMSMSSSMSAMSAMXSMAMSMMMSMSMSXSMMXMAMMAAAXSSSMMSXMAAXMXMAXMMXSXMXSAXASAMXAMASMMMMSMASAMAXAXXSASMXMASASMAMAASXMMASAAAMAMMAMAAAMXSAMXMXA
    MSSSMSXMMSMAMAMMMMMMXSAXAMAMAXXXXAXXAASAMAMXSMSXMAXAAXMSMMMSMMXMSMMSMSXMMSMXXXXAMAMMXAXAMMMSSMSSSMMAMAASXMASMAMMMMSXXMAXMXXAXMASAMMAASXMSMMS
    XXAMASXMASMSMXMASXSAMSASXSXSXSXSMMSXMAMAXMMXMAMAMAMMMMMXMAAMAMAMXAAXAMASAAXSXSMMMXSASMSMSMAXMXAAAXMAMXMAAMXMMSXSAMXSMMMXMASAMMAMAAXMAMAXASAM
    XMMMAMXMXSAXXAMXSAMSXMMMXAMXXMXSAAAXXASXMASMSASAMASXSXMASMXSAMASXSMMMMAMXMXMAMXSAMXAAAAXAMSSSMMXMMMXXAXXSMSAXAASMMAMXAMXXXAAMMMSAMXSMSMSAMXS
    SMXMASASXMAMSASAMAMMSMSXXSMXASAMMMSSXMAXSMAAMAXXMXSAMMSMSAXSXSASXAAASMSSSMSMXMAMAMXMMSMMMXXAMXXAAMSSSMSXMAMXMMXMAMASMMMMAAMMMXMAMMXSAAXXXAMA
    XMASASMMAMXMMXMASMMAAMXMAXAMXMMXSXAXMXAXSXMMMSMMSAMAMXAAMMMMXMASMMMSAXMAMAAXSMXMSMSMXXMASMMAMASXSMAXXAMMMAMMXXAMXMMSAXSAMXXXSXMASXAMSMSMMMXS
    SXMXASXSAMMAXAXMXXMSMSAAXMAXSASAXMAMMMSSMXXXAAAXMAMMMSMSMSAMMAAXASMXMXMAMMMMXAAAAAXMASXSMASMMXSMAMMSMMMASASMMSXSASASMMAAXXSAMASAMMMMMMAAMSAX
    XASMMMASMSASXSSXSAMAASASXMAMMAMMSSMMSAMAMMMMMSMMMMMAAXAMMSASAMXSMMAAXMMMSAAMSSMSMSMMAMMMMAMXMAXXASXSAXSASMSAMAXSAMXMXSSMMXSAXAMASMXAMXSSMMAM
    SAMAASXSAAXMAMAXSAMMXMAXAMSMMXMXAAMAMMSASAAAAMASASXMMXXMASAMXMXSXMSSMAXAMMSMAXMXMAAMASASASXMXSXSXSAMXMMAMMSAMMMMXMSXAMASMASXMXSMXXMSSMAAXMAM
    MMMAMSAMXSMMAMSMSMMMMMMMMMMAXMSMSSMASMSAMMSMXSAMMXAAASMMMMMMASMMAMAMXSMMSAMXMMSAMMSMMSASAXXAMMAMAMAMMSMSMAXMMMAXAXAMXSAXMAXSMXAMAXAAAMSSMSAS
    SASXSMAMAMMSSSMASAMXAAMXSASMMAXXMAMXMAMXMAMAAMAXXSSMMAMAMXXSAMASXMASXXAXMASXXASASAXXAMXMXMXSAXAMAMXMXAAAXSMSSSMSMSMMXMASMXMAXMAMXMSMMMXMASXS
    AXASXMAMAXMAMAMAMMMSSMSAMXMXAXSMSSMMSXMAXMMMMSMMAAAXXASAXSAMAXMMSMSMAMMMSMMXMASAMAXMXSAMMXMMMSMSMXAMXMMMMMAXAAXAAAAXAAXMASMMASMMXMAAXMAMXMXM
    MXMSXSXMAMMXSSMMSAMXAAMASMSMSXSASMSAAAAMMSXMXAMMSMMSSMXMSMAMAMMAMXAAMXAAAMMXMAXXAMXSAMAXXAMAASMAMSASXSASAMSMMMSMSMSMMMMMAMMXAAXMXSAMMXAMAAAA
    XSXSASAMMXSAAAAXSMXXXMSSMAAAXMMSMAAMMSXMAMAMMMXMAAXAASXSAMAMMSMASMXSMMSSSXMAMMSSMMXSASAMXXXASXXAXXXMASASMXMASAXXMAAAXXAMXSSMSSMSAXXMMSASXSMS
    XMAMAMAMAAMMSMMMSASMSMSXMSMMMAXXMXMXXXXMASAMXAASMMMSMMXMAMXMAXMXMMSAAXMAXAXSSMAAAMMSXMASMXSMMMMSSMSMMMMMXAAXAXSAMSSXMMSXMMAAXXAMASMMXAXXAAXA
    XMASASAMMXSAAAAAXAAAAXMAMAASMSMMMMXSMMASAXMSMSXSAMXMXMAMXMSMSSSMAXASXMMMMXMMAMSSMMAXMXAMMAAAMXAAAXAAXMASXSSMMSMMMAAXSXAMAXMMMMSMAMAASXMXMMSM
    MSXSAMMXSAMMSSMMMMMSMXXMMSXMAXMASAAAAMMMSSMXMASMXMASAMASAAXAAAMSMXMAMXMASMMSAMXXAMXSAXSAMXMXMMMSXSMSMMMAAAAAXXAAMMSMSAMXXAXAXAAMSSSMSAMXAAXX
    AXAMAMSAMMSAMXMMSMMAMSSSMXXMXMSSMMMSSMAAMXMMMXMSAMASASASMSMMMSMSSSXAMSXMMAAMMMMSXMASXMXAAMXXXMAMMXAMAAXMMSMMMMSMXAMAXSMAAXSSXMXSMXXASAMSAMSA
    SMMMMXMASAXMSASAAASXSXAAASXMXMXMXAXMXXMSMAMASAASXSMSAMMMMMMAMMAMASAMXSAXSSMSXAXSXMMSASXSMMXMASAMXMXXAMXXAMMAXXMMSMMSMAMXSAAAASXMMAMMMAMXASXM
    AXMAMASMMMSMSAMMSMMMMMMMMMAMAXAMMSSMAMMAXMSAXMMMXXAMMMXAAASMSMAMMXXMAMAMAXAMMSSMASASMMXAASMMMSAAXAAXSMMMXSXSXSAAAXMASMXAXMMMMMAAMXMASXMSXMAM
    SXMASAXAAXAAMAMAMXMASMMSXSAMXMAXAAAMSMSMSXMMXSAASMXMMMSSSMSAAXXMXXSMSSMAMMSMAXAXXMASXMSXMMAAAXMMMSMMXAXSXMMMAXMXSMSASXMMXAMMAXMMMXSXMMMMXXAM
    MASASXSSMSSSSSMASASXMAAXASAMMSSMMSSMAMAASMMAAMMSMSAXAXMAXAMXMMSSSMXAMAAXMAAXXSAMXMMMAMASMSSMSSMXAASAMSMMASAMSMSAMMMSSMASXMMSSSMMSAMAXMASMSSS
    SAMMSAMAAXAAAXMASMMMSMMMMSAMAAAAXMAMSSMMMAMMSSXMASXSXSMXMXMAXAAAASMXMASMMSSSXMXMASASXMAMXAAAAXAMSSSSXXASAMMXMAMXSMMAXAMSAAAAXAMAMASMMSAXMAAM
    MMSAMXSMMMMMMMAMSMXMASAMXSXMMSSMSAXMXXXXSXMMMAMMXMMAMXMAMXSXSMMSMMXAMXMAXAMXMXXSXMASXMXMMSMMMMSAMXMASXXMSSXSMSMMMMMMSSXSMMMSSXMASXMAXMXSMMMM
    """
}