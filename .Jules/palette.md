## 2024-05-22 - Flutter Custom Button Accessibility
**Learning:** Custom buttons using  in Flutter require explicit  wrapping to be accessible.  is crucial for TalkBack/VoiceOver support, especially when loading states replace the text.
**Action:** Always wrap custom interactive widgets with  to provide role and state information.
