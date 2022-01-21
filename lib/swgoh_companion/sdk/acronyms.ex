defmodule SWGOHCompanion.SDK.Acronyms do

  @acronyms %{
    "at" => "Ahsoka Tano",
    "av" => "Asajj Ventress",
    "bs" => "Bastila Shan",
    "bsf" => "Bastila Shan (Fallen)",
    "c3po" => "C-3PO",
    "cc" => "Chief Chirpa",
    "dr" => "Darth Revan",
    "dv" => "Darth Vader",
    "eb" => "Ezra Bridger",
    "es" => "Ewok Scout",
    "ee" => "Ewok Elder",
    "gas" => "General Skywalker",
    "gba" => "Geonosian Brood Alpha",
    "gk" => "General Kenobi",
    "gmy" => "Grand Master Yoda",
    "gso" => "Geonosian Soldier",
    "gsp" => "Geonosian Spy",
    "hk" => "HK-47",
    "hs" => "Hera Syndulla",
    "jb" => "Jolee Bindo",
    "jka" => "Jedi Knight Anakin",
    "jkr" => "Jedi Knight Revan",
    "kj" => "Kanan Jarrus",
    "mt" => "Mother Talzin",
    "mw" => "Mace Windu",
    "ni" => "Nightsister Initiate",
    "nz" => "Nightsister Zombie",
    "od" => "Old Daka",
    "padme" => "Padmé Amidala",
    "ptl" => "Poggle the Lesser",
    "set" => "Sith Empire Trooper",
    "sf" => "Sun Fac",
    "zeb" => "Garazeb \"Zeb\" Orrelios"
  }


  def expand_acronyms(characters) do
    characters
    |> Enum.map(&{&1, Map.get(@acronyms, String.downcase(&1), &1)})
  end
end
