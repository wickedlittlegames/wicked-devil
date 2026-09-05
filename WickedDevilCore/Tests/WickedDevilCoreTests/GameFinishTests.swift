import XCTest
@testable import WickedDevilCore

/// `Platform action:` case 100 — reaching the goal ends the run after a
/// one-second delay that lives in the presentation layer.
final class GameFinishTests: XCTestCase {

    private func makeGame(store: InMemoryUserDataStore = InMemoryUserDataStore()) -> (Game, User) {
        let user = User(store: store)
        let player = Player(position: Vec2(x: 160, y: 100))
        let game = Game(world: 1, level: 1, player: player, user: user)
        return (game, user)
    }

    func testFinishWinningEndsTheRunAndBanksJumps() {
        let (game, user) = makeGame()
        game.player.jumps = 7
        let startingJumps = user.jumps

        let event = game.finish(didWin: true)

        XCTAssertEqual(event, .gameOver(didWin: true))
        XCTAssertTrue(game.isGameover)
        XCTAssertTrue(game.didWin)
        XCTAssertEqual(user.jumps, startingJumps + 7)
        // A win is not a death.
        XCTAssertEqual(game.player.deaths, 0)
    }

    func testFinishWithoutBigCollectablesLoses() {
        let (game, _) = makeGame()

        let event = game.finish(didWin: false)

        XCTAssertEqual(event, .gameOver(didWin: false))
        XCTAssertTrue(game.isGameover)
        XCTAssertFalse(game.didWin)
    }

    func testFinishIsIdempotent() {
        let (game, user) = makeGame()
        game.player.jumps = 3

        XCTAssertNotNil(game.finish(didWin: true))
        let jumpsAfterFirst = user.jumps

        XCTAssertNil(game.finish(didWin: false), "a finished run cannot be finished again")
        XCTAssertTrue(game.didWin, "the second call must not flip the result")
        XCTAssertEqual(user.jumps, jumpsAfterFirst, "jumps must not be banked twice")
    }

    func testCheckGameOverAfterFinishReportsNothing() {
        let (game, _) = makeGame()
        game.finish(didWin: true)

        XCTAssertNil(game.checkGameOver())
    }

    func testDeathStillCountsADeath() {
        let (game, user) = makeGame()
        game.player.health = 0

        let event = game.checkGameOver()

        XCTAssertEqual(event, .gameOver(didWin: false))
        XCTAssertEqual(game.player.deaths, 1)
        XCTAssertEqual(user.deaths, 1)
    }
}
