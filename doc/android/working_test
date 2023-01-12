package co.frog.pokedex

import android.graphics.Bitmap
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.lifecycle.testing.TestLifecycleOwner
import app.cash.turbine.test
import co.frog.pokedex.data.repositories.PokemonDataRepository
import co.frog.pokedex.data.structures.PokemonDetails
import co.frog.pokedex.data.structures.ResultOf
import co.frog.pokedex.data.structures.api.NamedAPIResource
import co.frog.pokedex.data.structures.api.NamedAPIResourceList
import co.frog.pokedex.domain.ExtractPokemonDetailsUseCase
import co.frog.pokedex.ui.PokedexViewModel
import dagger.hilt.android.testing.HiltAndroidTest
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.*
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.kotlin.any
import org.mockito.kotlin.doReturn
import org.mockito.kotlin.mock


/*
1. Adapt Hilt for the test
Mock all the injected dependencies, and isolate the ViewModel
@HiltAndroidTest
2. to skip delays in the tests
Dispatchers.setMain(UnconfinedTestDispatcher())
3. to simulate the a test lifecycleOwner to test the flow
4. Turbine and awaitItem to wait for the emits
5. assertThat to have nice assertions with good error reporting
testLifecycleOwner = TestLifecycleOwner()
 */

@HiltAndroidTest
class PokedexViewModelUnitTest {

    lateinit var pokeViewModel: PokedexViewModel

    private fun getDummyPokemonList(): NamedAPIResourceList {
        val results = listOf(
            NamedAPIResource(
                name = "Pokémon1",
                url = "https://pokeapi.co/api/v2/pokemon/1/",
            )
        )
        return NamedAPIResourceList(
            count = results.size,
            next = null,
            previous = null,
            results = results,
        )
    }

    private val testingPokemonList = getDummyPokemonList()
    private val testingPokemonDetails = listOf(
        PokemonDetails(
            name = testingPokemonList.results[0].name,
            id = 1,
            spriteUrl = "url",
            sprite = mock<Bitmap>()
        )
    )

    @OptIn(ExperimentalCoroutinesApi::class)
    @BeforeEach
    fun beforeEach() {
        // https://github.com/Kotlin/kotlinx.coroutines/blob/master/kotlinx-coroutines-test/MIGRATION.md
        // this dispatcher skips delays
        Dispatchers.setMain(UnconfinedTestDispatcher())
        val pokemonDataRepository = mock<PokemonDataRepository> {
            onBlocking { getPokemon() } doReturn testingPokemonList
        }
        val extractPokemonDetailsUseCase = mock<ExtractPokemonDetailsUseCase> {
            on { invoke(any()) } doReturn testingPokemonDetails
        }
        pokeViewModel = PokedexViewModel(pokemonDataRepository, extractPokemonDetailsUseCase)
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    @AfterEach
    fun afterEach() {
        Dispatchers.resetMain()
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    @Test
    fun testGetPokemon() = runTest {
        pokeViewModel.pokemonList.test { // test is needed with turbine
            val actual = mutableListOf<ResultOf<List<PokemonDetails>>>()
            val testLifecycleOwner = TestLifecycleOwner()
            testLifecycleOwner.lifecycleScope.launch {
                testLifecycleOwner.lifecycle.repeatOnLifecycle(Lifecycle.State.STARTED) {
                    pokeViewModel.pokemonList.collect {
                        actual.add(it)
                    }
                }
            }
            testLifecycleOwner.currentState = Lifecycle.State.STARTED
            // we must wait for 2 items because the coroutine is waiting on the collec
            // and the library turbine helps a lot for that using awaitItem()
            awaitItem()
            awaitItem()
            assertThat("number of values", actual.size, equalTo(2))
            assertThat("Loading value", actual[0], equalTo(ResultOf.Loading("")))
            assertThat("Success value", actual[1], equalTo(ResultOf.Success(testingPokemonDetails)))
        }
    }
}
