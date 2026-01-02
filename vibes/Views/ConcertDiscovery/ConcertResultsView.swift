import SwiftUI

struct ConcertResultsView: View {
    @Bindable var viewModel: ConcertDiscoveryViewModel

    var body: some View {
        Group {
            if viewModel.isLoadingConcerts {
                loadingView
            } else if let error = viewModel.concertsError {
                errorView(error)
            } else if viewModel.concerts.isEmpty {
                emptyStateView
            } else {
                concertList
            }
        }
        .navigationTitle("Concerts")
        .navigationBarTitleDisplayMode(.large)
    }

    private var concertList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.concerts) { rankedConcert in
                    ConcertRow(rankedConcert: rankedConcert) {
                        openTicketURL(rankedConcert.concert.ticketURL)
                    }
                    .padding(.horizontal)
                    Divider()
                        .padding(.leading, 84)
                }
            }
            .padding(.top)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Searching for concerts...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("This may take a moment")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView {
            Label("Error", systemImage: "exclamationmark.triangle")
        } description: {
            Text(error.localizedDescription)
        } actions: {
            Button("Try Again") {
                Task {
                    await viewModel.findConcerts()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Concerts Found", systemImage: "ticket")
        } description: {
            Text("No upcoming concerts found for your selected artists in the US. Try adding more artists or check back later.")
        }
    }

    private func openTicketURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    NavigationStack {
        ConcertResultsView(viewModel: {
            let vm = ConcertDiscoveryViewModel()
            vm.concerts = [
                RankedConcert(
                    concert: Concert(
                        id: "1",
                        artistName: "Drake",
                        venueName: "Madison Square Garden",
                        venueAddress: "4 Pennsylvania Plaza",
                        city: "New York",
                        date: Date(),
                        priceRange: "USD 150 - 500",
                        ticketURL: "https://ticketmaster.com"
                    ),
                    artistRank: 1,
                    isHomeCity: true
                ),
                RankedConcert(
                    concert: Concert(
                        id: "2",
                        artistName: "Drake",
                        venueName: "TD Garden",
                        venueAddress: "100 Legends Way",
                        city: "Boston",
                        date: Date().addingTimeInterval(86400 * 3),
                        ticketURL: "https://ticketmaster.com"
                    ),
                    artistRank: 1,
                    isHomeCity: false
                ),
                RankedConcert(
                    concert: Concert(
                        id: "3",
                        artistName: "Taylor Swift",
                        venueName: "SoFi Stadium",
                        venueAddress: "1001 Stadium Dr",
                        city: "Los Angeles",
                        date: Date().addingTimeInterval(86400 * 7),
                        ticketURL: "https://ticketmaster.com"
                    ),
                    artistRank: 2,
                    isHomeCity: false
                )
            ]
            vm.hasSearchedConcerts = true
            return vm
        }())
    }
}
