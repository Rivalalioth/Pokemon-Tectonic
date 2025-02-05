# @deprecated Use {Game.save} instead. pbSave is slated to be removed in v20.
def pbSave(safesave = false)
    Deprecation.warn_method('pbSave', 'v20', 'Game.save')
    Game.save(safe: safesave)
  end

  def properlySave
    if $storenamefilesave.nil?
      count = FileSave.count
      SaveData.changeFILEPATH(FileSave.name(count+1))
      $storenamefilesave = FileSave.name(count+1)
    end
    setProperSavePath
    return Game.save
  end
  
  def pbEmergencySave
      oldscene = $scene
      $scene = nil
      pbMessage(_INTL("The script is taking too long. The game will restart."))
      return if !$Trainer
      # It will store the last save file when you dont file save
      setProperSavePath
      if SaveData.exists?
          File.open(SaveData::FILE_PATH, 'rb') do |r|
            File.open(SaveData::FILE_PATH + '.bak', 'wb') do |w|
              while s = r.read(4096)
                w.write s
              end
            end
          end
      end
      if savingAllowed?
          if Game.save
              pbMessage(_INTL("\\se[]The game was saved.\\me[GUI save game]"))
          else
              pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
          end
      end
      pbMessage(_INTL("The previous save file has been backed up.\\wtnp[30]"))
      $scene = oldscene
  end

  def makeBackupSave
    setProperSavePath
    SaveData.save_backup(SaveData::FILE_PATH)
  end

  def savingAllowed?()
    begin
      return false if GameData::MapMetadata.get($game_map.map_id).saving_blocked
      #return false if $PokemonGlobal.tournament&.tournamentActive?
    rescue
      return true
    end
    return true
  end
  
  def showSaveBlockMessage()
    pbMessage(_INTL("Saving is not allowed at the moment."))
  end

  def setProperSavePath
    SaveData.changeFILEPATH($storenamefilesave.nil? ? FileSave.name : $storenamefilesave)
  end
  
  def pbCustomMessageForSave(message,commands,index,&block)
    return pbMessage(message,commands,index,&block)
  end