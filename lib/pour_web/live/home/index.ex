defmodule PourWeb.HomeLive.Index do
  use PourWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />
    <div class="bg-white">
      <main>
        <div class="relative z-10 mt-16 bg-gray-900 pb-20  sm:pb-24 xl:pb-0">
          <div class="absolute inset-0 overflow-hidden" aria-hidden="true">
            <div class="absolute top-[calc(50%-36rem)] left-[calc(50%-19rem)] transform-gpu blur-3xl">
              <div
                class="aspect-1097/1023 w-[68.5625rem] bg-linear-to-r from-[#ff4694] to-[#776fff] opacity-25"
                style="clip-path: polygon(74.1% 44.1%, 100% 61.6%, 97.5% 26.9%, 85.5% 0.1%, 80.7% 2%, 72.5% 32.5%, 60.2% 62.4%, 52.4% 68.1%, 47.5% 58.3%, 45.2% 34.5%, 27.5% 76.7%, 0.1% 64.9%, 17.9% 100%, 27.6% 76.8%, 76.1% 97.7%, 74.1% 44.1%)"
              >
              </div>
            </div>
          </div>
          <div class="mx-auto flex max-w-7xl flex-col items-center gap-x-8 gap-y-10 px-6 sm:gap-y-8 lg:px-8 xl:flex-row xl:items-stretch">
            <div class="-mt-8 w-full max-w-2xl xl:-mb-8 xl:w-96 xl:flex-none">
              <div class="relative aspect-2/1 h-full md:-mx-8 xl:mx-0 xl:aspect-auto">
                <img
                  class="absolute inset-0 size-full rounded-2xl bg-gray-800 object-cover shadow-2xl"
                  src="/images/splash.jpeg"
                  alt=""
                />
              </div>
            </div>
            <div class="w-full max-w-2xl xl:max-w-none xl:flex-auto xl:px-16 xl:py-24">
              <figure class="relative isolate pt-6 sm:pt-12">
                <svg
                  viewBox="0 0 162 128"
                  fill="none"
                  aria-hidden="true"
                  class="absolute top-0 left-0 -z-10 h-32 stroke-white/20"
                >
                  <path
                    id="b56e9dab-6ccb-4d32-ad02-6b4bb5d9bbeb"
                    d="M65.5697 118.507L65.8918 118.89C68.9503 116.314 71.367 113.253 73.1386 109.71C74.9162 106.155 75.8027 102.28 75.8027 98.0919C75.8027 94.237 75.16 90.6155 73.8708 87.2314C72.5851 83.8565 70.8137 80.9533 68.553 78.5292C66.4529 76.1079 63.9476 74.2482 61.0407 72.9536C58.2795 71.4949 55.276 70.767 52.0386 70.767C48.9935 70.767 46.4686 71.1668 44.4872 71.9924L44.4799 71.9955L44.4726 71.9988C42.7101 72.7999 41.1035 73.6831 39.6544 74.6492C38.2407 75.5916 36.8279 76.455 35.4159 77.2394L35.4047 77.2457L35.3938 77.2525C34.2318 77.9787 32.6713 78.3634 30.6736 78.3634C29.0405 78.3634 27.5131 77.2868 26.1274 74.8257C24.7483 72.2185 24.0519 69.2166 24.0519 65.8071C24.0519 60.0311 25.3782 54.4081 28.0373 48.9335C30.703 43.4454 34.3114 38.345 38.8667 33.6325C43.5812 28.761 49.0045 24.5159 55.1389 20.8979C60.1667 18.0071 65.4966 15.6179 71.1291 13.7305C73.8626 12.8145 75.8027 10.2968 75.8027 7.38572C75.8027 3.6497 72.6341 0.62247 68.8814 1.1527C61.1635 2.2432 53.7398 4.41426 46.6119 7.66522C37.5369 11.6459 29.5729 17.0612 22.7236 23.9105C16.0322 30.6019 10.618 38.4859 6.47981 47.558L6.47976 47.558L6.47682 47.5647C2.4901 56.6544 0.5 66.6148 0.5 77.4391C0.5 84.2996 1.61702 90.7679 3.85425 96.8404L3.8558 96.8445C6.08991 102.749 9.12394 108.02 12.959 112.654L12.959 112.654L12.9646 112.661C16.8027 117.138 21.2829 120.739 26.4034 123.459L26.4033 123.459L26.4144 123.465C31.5505 126.033 37.0873 127.316 43.0178 127.316C47.5035 127.316 51.6783 126.595 55.5376 125.148L55.5376 125.148L55.5477 125.144C59.5516 123.542 63.0052 121.456 65.9019 118.881L65.5697 118.507Z"
                  />
                  <use href="#b56e9dab-6ccb-4d32-ad02-6b4bb5d9bbeb" x="86" />
                </svg>
                <blockquote class="text-xl/8 font-semibold text-white sm:text-2xl/9">
                  <p>
                    At The Georgetown Pour, we believe that wine is more than just a beverage—it is a bridge to community, a reflection of the land, and an expression of generosity.
                  </p>
                </blockquote>
                <figcaption class="mt-8 text-base">
                  <div class="font-semibold text-white">- Tom and Julia</div>
                </figcaption>
              </figure>
            </div>
          </div>
        </div>
        
    <!-- Info section -->
        <div class="relative isolate mt-16 bg-white px-6 sm:mt-36 lg:px-8">
          <div
            class="absolute inset-x-0 -top-3 -z-10 transform-gpu overflow-hidden px-36 blur-3xl"
            aria-hidden="true"
          >
            <div
              class="mx-auto aspect-1155/678 w-[72.1875rem] bg-linear-to-tr from-[#ff80b5] to-[#9089fc] opacity-30"
              style="clip-path: polygon(74.1% 44.1%, 100% 61.6%, 97.5% 26.9%, 85.5% 0.1%, 80.7% 2%, 72.5% 32.5%, 60.2% 62.4%, 52.4% 68.1%, 47.5% 58.3%, 45.2% 34.5%, 27.5% 76.7%, 0.1% 64.9%, 17.9% 100%, 27.6% 76.8%, 76.1% 97.7%, 74.1% 44.1%)"
            >
            </div>
          </div>
          <div class="mx-auto max-w-2xl sm:text-center">
            <p class="mt-2 text-4xl font-semibold tracking-tight text-pretty text-gray-900 sm:text-5xl sm:text-balance">
              The Georgetown Pour
            </p>
            <p class="mt-6 text-lg/8 text-gray-600">
              Each month, we carefully select a handful of exceptional wines from small family farms and offer them in limited quantities to our members. By prioritizing sustainable and ethical viticulture, we aim to foster a culture of appreciation for wines made with integrity and care.
            </p>
          </div>
          <div class="mx-auto mt-16 grid max-w-lg grid-cols-1 items-center gap-y-6 sm:mt-20 sm:gap-y-0 lg:max-w-4xl lg:grid-cols-3">
            <div class="rounded-3xl rounded-t-3xl bg-white/60 p-8 ring-1 ring-gray-900/10 sm:mx-8 sm:rounded-b-none sm:p-10 lg:mx-0 lg:rounded-tr-none lg:rounded-bl-3xl">
              <h3 id="tier-hobby" class="text-base/7 font-semibold text-indigo-600">Who We Are</h3>

              <p class="mt-6 text-base/7 text-gray-600">
                We are Tom and Julia, longtime fine wine importers who recently made Georgetown their home. Our club is dedicated to sharing wines that tell a story—wines rooted in organic farming, small-scale craftsmanship, and the preservation of local commerce.
              </p>
              <ul role="list" class="mt-8 space-y-3 text-sm/6 text-gray-600 sm:mt-10"></ul>
            </div>
            <div class="relative rounded-3xl bg-gray-900 p-8 ring-1 shadow-2xl ring-gray-900/10 sm:p-10">
              <h3 id="tier-enterprise" class="text-base/7 font-semibold text-indigo-400">
                How it Works
              </h3>

              <ul role="list" class="mt-8 space-y-3 text-sm/6 text-gray-300 sm:mt-10">
                <li class="flex gap-x-3">
                  <svg
                    class="h-6 w-5 flex-none text-indigo-400"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                    aria-hidden="true"
                    data-slot="icon"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M16.704 4.153a.75.75 0 0 1 .143 1.052l-8 10.5a.75.75 0 0 1-1.127.075l-4.5-4.5a.75.75 0 0 1 1.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 0 1 1.05-.143Z"
                      clip-rule="evenodd"
                    />
                  </svg>
                  With each offering, in collaboration with Now You’re Cooking we make available 4 wines
                </li>
                <li class="flex gap-x-3">
                  <svg
                    class="h-6 w-5 flex-none text-indigo-400"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                    aria-hidden="true"
                    data-slot="icon"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M16.704 4.153a.75.75 0 0 1 .143 1.052l-8 10.5a.75.75 0 0 1-1.127.075l-4.5-4.5a.75.75 0 0 1 1.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 0 1 1.05-.143Z"
                      clip-rule="evenodd"
                    />
                  </svg>
                  Order 6 or more bottles of wine at a time here
                </li>
                <li class="flex gap-x-3">
                  <svg
                    class="h-6 w-5 flex-none text-indigo-400"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                    aria-hidden="true"
                    data-slot="icon"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M16.704 4.153a.75.75 0 0 1 .143 1.052l-8 10.5a.75.75 0 0 1-1.127.075l-4.5-4.5a.75.75 0 0 1 1.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 0 1 1.05-.143Z"
                      clip-rule="evenodd"
                    />
                  </svg>
                  Wines are then shipped for pickup at Now You’re Cooking in Bath. The store will contact you with pickup details.
                </li>
              </ul>
              <a
                href={~p"/lot"}
                aria-describedby="tier-enterprise"
                class="mt-8 block rounded-md bg-indigo-500 px-3.5 py-2.5 text-center text-sm font-semibold text-white shadow-xs hover:bg-indigo-400 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500 sm:mt-10"
              >
                See the Wines
              </a>
            </div>
            <div class="rounded-3xl rounded-t-3xl bg-white/60 p-8 ring-1 ring-gray-900/10 sm:mx-8 sm:rounded-b-none sm:p-10 lg:mx-0 lg:rounded-tl-none lg:rounded-br-3xl">
              <h3 id="tier-hobby" class="text-base/7 font-semibold text-indigo-600">What's Next</h3>

              <ul role="list" class="mt-8 space-y-3 text-sm/6 text-gray-600 sm:mt-10">
                <li class="flex gap-x-3">
                  <svg
                    class="h-6 w-5 flex-none text-indigo-600"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                    aria-hidden="true"
                    data-slot="icon"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M16.704 4.153a.75.75 0 0 1 .143 1.052l-8 10.5a.75.75 0 0 1-1.127.075l-4.5-4.5a.75.75 0 0 1 1.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 0 1 1.05-.143Z"
                      clip-rule="evenodd"
                    />
                  </svg>
                  Tastings: We are exploring the possibility of hosting monthly gatherings—stay tuned!
                </li>
                <li class="flex gap-x-3">
                  <svg
                    class="h-6 w-5 flex-none text-indigo-600"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                    aria-hidden="true"
                    data-slot="icon"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M16.704 4.153a.75.75 0 0 1 .143 1.052l-8 10.5a.75.75 0 0 1-1.127.075l-4.5-4.5a.75.75 0 0 1 1.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 0 1 1.05-.143Z"
                      clip-rule="evenodd"
                    />
                  </svg>
                  Supporting Local: Our partnership with Now You’re Cooking allows for a seamless pickup experience and reinforces our commitment to local commerce.
                </li>
              </ul>
            </div>
          </div>
        </div>
        
    <!-- FAQ section -->
        <div class="mx-auto mt-32 max-w-7xl px-6 sm:mt-56 lg:px-8">
          <div class="mx-auto max-w-4xl">
            <h2 class="text-4xl font-semibold tracking-tight text-gray-900 sm:text-5xl">
              Frequently asked questions
            </h2>
            <dl class="mt-16 divide-y divide-gray-900/10">
              <div class="py-6 first:pt-0 last:pb-0">
                <dt>
                  <!-- Expand/collapse question button -->
                  <button
                    type="button"
                    class="flex w-full items-start justify-between text-left text-gray-900"
                    aria-controls="faq-0"
                    aria-expanded="false"
                  >
                    <span class="text-base/7 font-semibold">
                      How often will new wines be available?
                    </span>
                    <span class="ml-6 flex h-7 items-center">
                      <!--
                    Icon when question is collapsed.

                    Item expanded: "hidden", Item collapsed: ""
                  -->
                      <svg
                        class="size-6"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                        stroke="currentColor"
                        aria-hidden="true"
                        data-slot="icon"
                      >
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v12m6-6H6" />
                      </svg>
                      <!--
                    Icon when question is expanded.

                    Item expanded: "", Item collapsed: "hidden"
                  -->
                      <svg
                        class="hidden size-6"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                        stroke="currentColor"
                        aria-hidden="true"
                        data-slot="icon"
                      >
                        <path stroke-linecap="round" stroke-linejoin="round" d="M18 12H6" />
                      </svg>
                    </span>
                  </button>
                </dt>
                <dd class="mt-2 pr-12" id="faq-0">
                  <p class="text-base/7 text-gray-600">
                    Every month, we will have a new selection of wines available.
                  </p>
                </dd>
              </div>
              
    <!-- More questions... -->
            </dl>
          </div>
        </div>
      </main>
      
    <!-- Footer -->
      <footer class="mt-16 bg-gray-900 sm:mt-36">
        <div class="mx-auto max-w-7xl px-6 py-16 sm:py-24 lg:px-8 lg:py-16">
          <div class="md:grid md:grid-cols-6 md:gap-8">
            <div class="md:col-span-2">
              <h3 class="text-sm/6 font-semibold text-white">Wine Selection</h3>
              <ul role="list" class="mt-6 space-y-4">
                <li>
                  <a href="#" class="text-sm/6 text-gray-400 hover:text-white">Current Wines</a>
                </li>
                <li>
                  <a href="#" class="text-sm/6 text-gray-400 hover:text-white">Past Wines</a>
                </li>
              </ul>
            </div>
            <div class="mt-10 col-span-2 md:mt-0">
              <h3 class="text-sm/6 font-semibold text-white">Ordering</h3>
              <ul role="list" class="mt-6 space-y-4">
                <li>
                  <a href="#" class="text-sm/6 text-gray-400 hover:text-white">All My Orders</a>
                </li>
                <li>
                  <a href="#" class="text-sm/6 text-gray-400 hover:text-white">
                    Place a New Order
                  </a>
                </li>
              </ul>
            </div>
            <div class="mt-10 md:mt-0">
              <h3 class="text-sm/6 font-semibold text-white">Admin</h3>
              <ul role="list" class="mt-6 space-y-4">
                <li>
                  <a href={~p"/admin/wines"} class="text-sm/6 text-gray-400 hover:text-white">
                    Manage Wine Library
                  </a>
                </li>
                <li>
                  <a href={~p"/lot"} class="text-sm/6 text-gray-400 hover:text-white">
                    Manage Current Lot
                  </a>
                </li>
                <li>
                  <a href="#" class="text-sm/6 text-gray-400 hover:text-white">
                    Manage Orders
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </footer>
    </div>
    """
  end
end
