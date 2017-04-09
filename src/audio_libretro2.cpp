/*
 * This file is part of EasyRPG Player.
 *
 * EasyRPG Player is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * EasyRPG Player is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with EasyRPG Player. If not, see <http://www.gnu.org/licenses/>.
 */

#if defined(USE_LIBRETRO) && defined(SUPPORT_AUDIO)
#include "audio_libretro2.h"
#include "output.h"

#include <vector>
#include <cstdlib>
#include <rthreads/rthreads.h>

namespace {
	LibretroAudio* instance = nullptr;
  std::vector<uint8_t> buffer;
  slock_t* mutex=NULL;
}

void LibretroAudio::AudioThreadCallback(){
    instance->LockMutex();
    instance->Decode(buffer.data(), buffer.size());
    instance->UnlockMutex();

    RenderAudioFrames(/* correct args here to libretro cb */);
}

LibretroAudio::LibretroAudio() :
	GenericAudio()
{
	instance = this;
    
  mutex = slock_new();
    
  buffer.resize(8192);

	SetFormat(44100, AudioDecoder::Format::S16, 2);
}

LibretroAudio::~LibretroAudio() {
	// clean up resources here
}

void LibretroAudio::LockMutex() const {
	slock_lock(mutex)
}

void LibretroAudio::UnlockMutex() const {
	slock_unlock(mutex)
}

#endif
