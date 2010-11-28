/////////////////////////////////////////////////////////////////////////////
// This file is part of EasyRPG Player.
//
// EasyRPG Player is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// EasyRPG Player is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with EasyRPG Player. If not, see <http://www.gnu.org/licenses/>.
/////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Headers
////////////////////////////////////////////////////////////
#include "game_battler.h"
#include <algorithm>
#include "main_data.h"

////////////////////////////////////////////////////////////
Game_Battler::Game_Battler() {
}

////////////////////////////////////////////////////////////
bool Game_Battler::HasState(int state_id) const {
	return (std::find(states.begin(), states.end(), state_id) != states.end());
}

////////////////////////////////////////////////////////////
std::vector<int> Game_Battler::GetStates() const {
	return states;
}

int Game_Battler::GetHp() const {
	return hp;
}

int Game_Battler::GetSp() const {
	return sp;
}
